class SendgridParseService
  def self.saveEmail(params)
    envelope = JSON.parse(params[:envelope])

    reply_message_id = $1 if params[:headers] =~ /In-Reply-To:\s<(.+)@/

    email = Plugins::FlexxPluginCrm::Email.create(
      subject: params[:subject],
      body: params[:html],
      from: envelope["from"],
      reply_message_id: reply_message_id,
      status: 'received',
    )

    envelope["to"].each do |to|
      email.email_recipients.create(
        to: to,
        status: 'received'
      )
    end
  end
end

