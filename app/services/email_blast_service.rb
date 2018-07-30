class EmailBlastService
  def initialize(recipients:, message:)
    @recipients = if recipients.is_a?(Array)
      recipients.map { |r| { email: r } }
    else
      [ { email: recipients } ]
    end
    @message = message
  end

  def call
    SendgridAdapter.new.send_email(
      from: {
        email: 'contact@flexx.co',
        name: 'Flexx'
      },
      to: @recipients,
      subject: 'Flexx Automated Campaign',
      body: @message)

    #TODO: save message in the database
  end
end

