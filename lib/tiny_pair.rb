require 'gemini-ai'

# if you can write the specification for some code, shouldn't the computer be
# able to write the implementation?
#
# get your Google Gemini API key ready, and then run the following code to see
# what happens:
#
#   tp = TinyPair.new(instructions: TinyPair::TEST_MODEL_INSTRUCTIONS)
#   puts tp.prompt(TinyPair::TEST_TEXT)
#
# override model instructions if you like:
#   tp = TinyPair.new(instructions: <your custom instructions>)
#
class TinyPair
  TEST_MODEL_INSTRUCTIONS = <<~INSTR
    You will be given some minitest tests in Ruby, and I want you to return the matching Ruby implementation.

    You should use the latest version of Ruby you know of, and try to keep the output code to an 80-column width.

    Only reply with a code snippet; no documentation, and no explanation.
  INSTR

  TEST_TEXT = <<~TEST_TEXT
    class TestCalc < Minitest::Test
      def test_add_two_and_two
        assert_equal 4, Calc.add(2, 2)
      end

      def test_add_two_and_seven
        assert_equal 9, Calc.add(2, 7)
      end

      def test_multi_three_and_five
        assert_equal 15, Calc.multi(3, 5)
      end

      def test_multi_six_and_nineteen
        assert_equal 114, Calc.multi(6, 19)
      end
    end
  TEST_TEXT

  attr_reader :msgs

  def initialize(api_key: ENV['TINY_PAIR_GEMINI_API_KEY'], model: ENV['TINY_PAIR_GEMINI_MODEL'], instructions: nil)
    @gemini = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: api_key,
      },
      options: { model: model, server_sent_events: false }
    )

    @msgs = []

    instructions&.strip!
    @msgs << {
      role: 'user',
      parts: [{ text: instructions.strip }]
    } if instructions && !instructions.empty?
  end

  # starts or continues a conversation with the msg
  def prompt(msg)
    if @msgs.length == 1
      @msgs.last[:parts] << { text: msg }
    else
      @msgs << { role: 'user', parts: [{ text: msg }] }
    end

    request_body = { contents: @msgs }
    response = @gemini.generate_content(request_body)
    candidate = response['candidates']&.first
    model_content = candidate&.dig('content')

    if model_content
      @msgs << model_content
      model_content.dig('parts', 0, 'text') || ""
    else
      error_message = "Failed to get a valid response from the API. Response: #{response.to_json}"
      @msgs.pop
      raise error_message
    end
  end
end
