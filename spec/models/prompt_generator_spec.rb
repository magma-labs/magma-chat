# spec/models/prompt_generator_spec.rb
require 'rails_helper'

RSpec.describe PromptGenerator, type: :model do
  let(:prompt_generator) { PromptGenerator.new }

  describe "#initialize" do
    it "initializes with empty lists of constraints, commands, resources, and performance evaluations" do
      expect(prompt_generator.instance_variable_get(:@constraints)).to eq([])
      expect(prompt_generator.instance_variable_get(:@commands)).to eq([])
      expect(prompt_generator.instance_variable_get(:@resources)).to eq([])
      expect(prompt_generator.instance_variable_get(:@performance_evaluation)).to eq([])
    end

    it "initializes with a default response format" do
      expected_response_format = {
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
      expect(prompt_generator.instance_variable_get(:@response_format)).to eq(expected_response_format)
    end
  end

  describe "#add_constraint" do
    it "adds a constraint to the constraints list" do
      constraint = "Sample constraint"
      prompt_generator.add_constraint(constraint)
      expect(prompt_generator.instance_variable_get(:@constraints)).to eq([constraint])
    end
  end

  describe "#add_command" do
    it "adds a command with label, name, and arguments to the commands list" do
      command_label = "Sample command label"
      command_name = "Sample command name"
      args = { sample_arg: "Sample value" }

      prompt_generator.add_command(command_label, command_name, args)

      expected_command = {
        label: command_label,
        name: command_name,
        args: args
      }
      expect(prompt_generator.instance_variable_get(:@commands)).to eq([expected_command])
    end

    it "adds a command with label, name, and no arguments to the commands list" do
      command_label = "Sample command label"
      command_name = "Sample command name"

      prompt_generator.add_command(command_label, command_name)

      expected_command = {
        label: command_label,
        name: command_name,
        args: {}
      }
      expect(prompt_generator.instance_variable_get(:@commands)).to eq([expected_command])
    end
  end

  describe "#add_resource" do
    it "adds a resource to the resources list" do
      resource = "Sample resource"
      prompt_generator.add_resource(resource)
      expect(prompt_generator.instance_variable_get(:@resources)).to eq([resource])
    end
  end

  describe "#add_performance_evaluation" do
    it "adds a performance evaluation item to the performance_evaluation list" do
      evaluation = "Sample evaluation"
      prompt_generator.add_performance_evaluation(evaluation)
      expect(prompt_generator.instance_variable_get(:@performance_evaluation)).to eq([evaluation])
    end
  end

  describe "#generate_numbered_list" do
    it "generates a numbered list for an array of strings" do
      items = ["item1", "item2", "item3"]
      expected_output = "1. item1\n2. item2\n3. item3"
      expect(prompt_generator.send(:generate_numbered_list, items)).to eq(expected_output)
    end

    it "generates a numbered list for an array of commands" do
      items = [
        { label: "label1", name: "name1", args: { arg1: "value1" } },
        { label: "label2", name: "name2", args: { arg2: "value2" } }
      ]
      expected_output = "1. label1: \"name1\", args: \"arg1\": \"value1\"\n2. label2: \"name2\", args: \"arg2\": \"value2\""
      expect(prompt_generator.generate_numbered_list(items, item_type: "command")).to eq(expected_output)
    end
  end

  describe "#generate_prompt_string" do
    it "generates a prompt string based on constraints, commands, resources, and performance evaluations" do
      prompt_generator.add_constraint("constraint1")
      prompt_generator.add_command("command1", "test_command", { arg1: "value1" })
      prompt_generator.add_resource("resource1")
      prompt_generator.add_performance_evaluation("evaluation1")

      expected_response_format = JSON.pretty_generate(prompt_generator.instance_variable_get(:@response_format))
      expected_output = <<~PROMPT.strip
        Constraints:
        1. constraint1

        Commands:
        1. command1: "test_command", args: "arg1": "value1"

        Resources:
        1. resource1

        Performance Evaluation:
        1. evaluation1

        You should only respond in JSON format as described below
        Response Format:
        #{expected_response_format}
        Ensure the response can be parsed by Ruby's JSON.parse method
      PROMPT

      expect(prompt_generator.generate_prompt_string.strip).to eq(expected_output.strip)
    end
  end
end
