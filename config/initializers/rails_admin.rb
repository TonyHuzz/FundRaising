RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.model Project do
    configure :due_date do
      strftime_format do
        '%d-%m-%Y %H:%M:%S'
      end
    end
  end

  config.model Pledge do
    configure :issue_date do
      strftime_format do
        '%d-%m-%Y %H:%M:%S'
      end
    end
  end

  config.model Payment do
    configure :paid_date do
      strftime_format do
        '%d-%m-%Y %H:%M:%S'
      end
    end


    configure :unpaid_payment_expire_date do
      strftime_format do
        '%d-%m-%Y %H:%M:%S'
      end
    end
  end
end
