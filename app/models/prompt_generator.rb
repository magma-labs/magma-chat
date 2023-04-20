class PromptGenerator
  def initialize
    @constraints = []
    @commands = []
    @resources = []
    @performance_evaluation = []
    @response_format = {
      thoughts: {
        text: "thought",
        reasoning: "reasoning",
        plan: "- short bulleted\n- list that conveys\n- long-term plan",
        criticism: "constructive self-criticism",
        speak: "thoughts summary to say to user"
      },
      command: {
        name: "command name",
        args: { "arg name": "value" }
      }
    }
  end

  def add_constraint(constraint)
    @constraints.append(constraint)
  end

  def add_command(command_label, command_name, args = {})
    command_args = args.transform_values(&:clone)
    command = {
      label: command_label,
      name: command_name,
      args: command_args
    }
    @commands.append(command)
  end

  def generate_command_string(command)
    args_string = command[:args].map { |key, value| "\"#{key}\": \"#{value}\"" }.join(", ")
    "#{command[:label]}: \"#{command[:name]}\", args: #{args_string}"
  end

  def add_resource(resource)
    @resources.append(resource)
  end

  def add_performance_evaluation(evaluation)
    @performance_evaluation.append(evaluation)
  end

  def generate_numbered_list(items, item_type: "list")
    items.each_with_index.map do |item, index|
      if item_type == "command"
        "#{index + 1}. #{generate_command_string(item)}"
      else
        "#{index + 1}. #{item}"
      end
    end.join("\n")
  end

  def generate_prompt_string
    formatted_response_format = JSON.pretty_generate(@response_format)
    <<~PROMPT
      Constraints:
      #{generate_numbered_list(@constraints)}

      Commands:
      #{generate_numbered_list(@commands, item_type: "command")}

      Resources:
      #{generate_numbered_list(@resources)}

      Performance Evaluation:
      #{generate_numbered_list(@performance_evaluation)}

      You should only respond in JSON format as described below
      Response Format:
      #{formatted_response_format}
      Ensure the response can be parsed by Ruby's JSON.parse method
    PROMPT
  end
end
