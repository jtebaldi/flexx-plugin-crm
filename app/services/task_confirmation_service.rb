class TaskConfirmationService
  def initialize(task:, number:)
    @task = task
    @number = number
  end

  def call
    TwilioAdapter.new.call_confirmation_flow(
      to: @number,
      parameters: {
        task_id: @task.id,
        appointment_time: @task.due_date.strftime('%b, %d %Y %I:%M %p')
      }
    )

    @task.notes.create(details: 'Confirmation message sent')
  end
end
