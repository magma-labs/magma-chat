class BotTool < ApplicationJob
  queue_as :high_priority_queue

end
