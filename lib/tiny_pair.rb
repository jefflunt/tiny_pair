require 'gemini-ai'

# if you can write the specification for some code, shouldn't the computer be
# able to write the implementation?
#
# get your Google Gemini API key ready, and then run the following code to see
# what happens:
#
#   tp = TinyPair.new
#   puts tp.(prompt: TinyPair::TEST_TEXT)
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

  def initialize(api_key: ENV['TINY_PAIR_GEMINI_API_KEY'], model: ENV['TINY_PAIR_GEMINI_MODEL'])
    @client = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: api_key,
      },
      options: { model: model, server_sent_events: false }
    )
  end

  # tests: the raw text of a series of minitest tests
  def llm(prompt:, instructions:)
    instructions = instructions.lines.map(&:strip).select{|l| !l.empty? }.join(' ')
    request_body = {
# NOTE: this doesn't seem to work, and I'm not sure why, so I put it in the
# prompt
#      system_instruction: {
#        role: 'user',
#        parts: { text: instructions }
#      },
      contents: {
        role: 'user',
        parts: [
          { text: instructions },
          { text: prompt }
        ]
      }
    }

    @client
      .generate_content(request_body)['candidates']
      .first['content']['parts']
      .first['text']
  end
end
