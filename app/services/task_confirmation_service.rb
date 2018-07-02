class TaskConfirmationService
  def initialize(task:, number:)
    @task = task
    @number = number
  end

  def call
    flow = TwilioAdapter.new.call_confirmation_flow(
      to: @number,
      parameters: {
        task_id: @task.id,
        due_time: @task.due_date
      }
    )

    @task.notes.create(details: 'Confirmation message sent')
  end
end
