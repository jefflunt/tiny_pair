require 'tiny_gemini'

# if you can write the specification for some code, shouldn't the computer be
# able to write the implementation?
#
# get your Google Gemini API key ready, and then run the following code to see
# what happens:
#
#   tp = TinyPair.new
#   puts tp.implement(tests: TinyPair::TESTS)
class TinyPair
  MODEL_INSTRUCTIONS = <<~INSTR
    You will be given some minitest tests in Ruby, and I want you to return the matching Ruby implementation.

    You should use the latest version of Ruby you know of, and try to keep the output code to an 80-column width

    Do not explain the code or any surrounding documentation: only provide the implementation code in plaintext and nothing else.
  INSTR

  TESTS = <<~TEST_TEXT
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

  def initialize(instructions: MODEL_INSTRUCTIONS)
    @client = TinyGemini.new(
      model: 'gemini-1.5-flash',
      system_instruction: MODEL_INSTRUCTIONS,
      api_key: ENV['GEMINI_KEY']
    )
  end

  # tests: the raw text of a series of minitest tests
  def implement(tests:)
    @client.prompt({
      parts: { text: tests },
      role: 'user'
    })
  end
end
