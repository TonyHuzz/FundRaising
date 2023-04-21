class PaymentsController < ApplicationController
  require 'digest'

  before_action :is_login?, only: [:mpg]
  before_action :get_pledge, only: [:mpg]

  skip_before_action :verify_authenticity_token, only: [:paid, :not_paid_yet, :notify, :canceled]

  HASH_KEY = "bcaJQNDigS1AwiDyXxVLumxlFkagQW5u"
  HASH_IV = "CXOTwHcgpYUzT1JP"

  def mpg   #從我們的網站頁面跳到藍星金流的中間頁面，此頁面會傳遞商品資訊的Form
    merchantID = 'MS348703456'
    version = '2.0'
    respondType = 'JSON'
    timeStamp = Time.now.to_i.to_s
    merchantOrderNo = "EX" + Time.now.to_i.to_s
    amt = @pledge.end_price
    itemDesc = @pledge.project_name

    data = "MerchantID=#{merchantID}&RespondType=#{respondType}&TimeStamp=#{timeStamp}&Version=#{version}&MerchantOrderNo=#{merchantOrderNo}&Amt=#{amt}&ItemDesc=#{itemDesc}&TradeLimit=300&Email=#{current_user.email}&CustomerURL=https://rails-fundraising-gogo.herokuapp.com/payments/not_paid_yet&ClientBackURL=https://rails-fundraising-gogo.herokuapp.com/payments/canceled"

    data = addpadding(data)
    aes = encrypt_data(data, HASH_KEY, HASH_IV, 'AES-256-CBC')
    checkValue = "HashKey=#{HASH_KEY}&#{aes}&HashIV=#{HASH_IV}"

    @merchantID = merchantID
    @tradeInfo = aes
    @tradeSha = Digest::SHA256.hexdigest(checkValue).upcase
    @version = version

    @pledge.update(merchantOrderNo: merchantOrderNo)
  end

  def paid
    if params["Status"] == "SUCCESS"

      tradeInfo = params["TradeInfo"]
      tradeSha = params["TradeSha"]

      checkValue = "HashKey=#{HASH_KEY}&#{tradeInfo}&HashIV=#{HASH_IV}"

      if tradeSha == Digest::SHA256.hexdigest(checkValue).upcase

        #解碼
        rawTradeInfo = decrypt_data(tradeInfo, HASH_KEY, HASH_IV, 'AES-256-CBC')

        #轉成JSON
        jsonResult = JSON.parse(rawTradeInfo)

        #取出json裡面的Result value, 我們需要的都在裡面
        result = jsonResult["Result"]

        #取出我們平台的訂單編號
        merchantOrderNo = result["MerchantOrderNo"]

        #利用訂單編號找出 pledge，同步付款的情況pledge 會是處於not_selected_yet
        pledge = Pledge.not_selected_yet.find_by(merchantOrderNo: merchantOrderNo)

        #如果有 pledge
        if pledge

          #建立一個新的payment, status會是已付款
          payment = Payment.paid.new(pledge: pledge)

          #payment裡面也會有 merchant_order_no，如果用不到可以拿掉這個column
          payment.merchant_order_no = merchantOrderNo

          #transaction_service_provider 設成 mpg
          payment.transaction_service_provider = "mpg"

          if result["PaymentType"] == "CREDIT"
            payment.payment_type = "credit_card"
            # TODO: add info from result
          elsif result["PaymentType"] == "WEBATM"
            payment.payment_type = "web_atm"
            # TODO: add info from result
          end

          #設已付款金額
          payment.end_price = result[:Amt]

          #儲存，加!會導致失敗的時候出現error
          payment.save!

          #pledge 改成已付款，Model裡面有override
          pledge.paid!
        end
      end
    end

    # TODO: to somewhere else
    redirect_to root_path
  end

  def not_paid_yet
    if params["Status"] == "SUCCESS"

      tradeInfo = params["TradeInfo"]
      tradeSha = params["TradeSha"]

      checkValue = "HashKey=#{HASH_KEY}&#{tradeInfo}&HashIV=#{HASH_IV}"
      if tradeSha == Digest::SHA256.hexdigest(checkValue).upcase

        #解碼
        rawTradeInfo = decrypt_data(tradeInfo, HASH_KEY, HASH_IV, 'AES-256-CBC')

        #轉成JSON
        jsonResult = JSON.parse(rawTradeInfo)

        result = jsonResult["Result"]

        merchantOrderNo = result["MerchantOrderNo"]

        #利用訂單編號找出 pledge，建立非同步交易的情況pledge 會是處於not_selected_yet
        pledge = Pledge.not_selected_yet.find_by(merchantOrderNo: merchantOrderNo)

        if pledge
          # 建立一個新的payment, status會是未付款
          payment = Payment.not_paid_yet.new(pledge: pledge)
          payment.merchant_order_no = merchantOrderNo

          payment.transaction_service_provider = "mpg"
          if result["PaymentType"] == "CVS"
            payment.payment_type = "cvs"
            # TODO: add info from result
          elsif result["PaymentType"] == "VACC"
            payment.payment_type = "atm"
            # TODO: add info from result
          elsif result["PaymentType"] == "BARCODE"
            payment.payment_type = "bar_code"
            # TODO: add info from result
          end
          payment.end_price = result["Amt"]
          payment.save!

          # pledge改成未付款
          pledge.not_paid!
        end
      end
    end

    # TODO: to somewhere else
    redirect_to root_path
  end

  def canceled
    redirect_to root_path
  end

  def notify
    if params["Status"] == "SUCCESS"

      tradeInfo = params["TradeInfo"]
      tradeSha = params["TradeSha"]

      checkValue = "HashKey=#{HASH_KEY}&#{tradeInfo}&HashIV=#{HASH_IV}"

      if tradeSha == Digest::SHA256.hexdigest(checkValue).upcase
        rawTradeInfo = decrypt_data(tradeInfo, HASH_KEY, HASH_IV, 'AES-256-CBC')
        jsonResult = JSON.parse(rawTradeInfo)
        result = jsonResult["Result"]
        merchantOrderNo = result["MerchantOrderNo"]

        #利用訂單編號找出 pledge，以建立付款但未付款的情況，pledge為not_paid
        pledge = Pledge.not_paid.find_by(merchantOrderNo: merchantOrderNo)
        if pledge
          # 只讓特定非即時付款方式狀態變化，避免二次執行
          if result["PaymentType"] == "CVS"
            pledge.payment.paid!
            pledge.paid!
            # TODO: add info from result
          elsif result["PaymentType"] == "VACC"
            pledge.payment.paid!
            pledge.paid!
            # TODO: add info from result
          elsif result["PaymentType"] == "BARCODE"
            pledge.payment.paid!
            pledge.paid!
            # TODO: add info from result
          else
            #Do Nothing
          end
        end
      end
    end

    respond_to do |format|
      format.json {render json: {result: "success"}}
    end
  end

  private

  def is_login?
    unless current_user
      flash[:error] = "您尚未登入"
      redirect_to login_path
      return
    end
  end

  def get_pledge
    @pledge = Pledge.not_selected_yet.find_by(id: params[:pledge_id], user: current_user)

    unless @pledge
      flash[:alert] = "沒有選擇贊助選項"
      redirect_to root_path
      return
    end
  end



  # =============
  # mpg methods
  # =============

  def addpadding(data, blocksize = 32)
    len = data.length
    pad = blocksize - ( len % blocksize)
    data += pad.chr * pad
    return data
  end

  def encrypt_data(data, key, iv, cipher_type)
    cipher = OpenSSL::Cipher.new(cipher_type)
    cipher.encrypt
    cipher.key = key
    cipher.iv = iv
    encrypted = cipher.update(data) + cipher.final
    return encrypted.unpack("H*")[0].upcase
  end

  def removedPadding(data)
    blocksize = 32
    loop do
      lastHex = data.last.bytes.first
      break if lastHex >= blocksize
      # 每一次只移除最後一個
      data = data[0...-1]
    end
    return data
  end

  def decrypt_data(data, key, iv, cipher_type)
    cipher = OpenSSL::Cipher.new(cipher_type)
    cipher.decrypt
    cipher.key = key
    cipher.iv = iv
    packedData = [data.downcase].pack('H*')
    data = removedPadding(cipher.update(packedData))
    begin
      return data + cipher.final
    rescue
      return data
    end
  end

end
