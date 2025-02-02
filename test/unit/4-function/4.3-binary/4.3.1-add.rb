section '4.3.1', '+' do
	describe 'when the first arg is a string' do
		it 'concatenates' do
			assert_result "1121a3", %|+ "112" "1a3"|
			assert_result "Plato Aristotle", %|+ "Plato" " Aristotle"|
			assert_result "Because why not?", %|++ "Because " "why" " not?"|
		end

		it 'coerces to a string' do
			assert_result 'truth is true', %|+ "truth is " TRUE|
			assert_result 'falsehood is false', %|+ "falsehood is " FALLSE|
			assert_result 'it is null and void', %|++ "it is " NULL " and void"|
			assert_result 'twelve is 12', %|+ "twelve is " 12|
		end

		it 'can be used to coerce to a string when the lhs is empty' do
			assert_result 'true', %|+ "" TRUE|
			assert_result 'false', %|+ "" FALSE|
			assert_result 'null', %|+ "" NULL|
			assert_result '1234', %|+ "" 1234|
			assert_result '-123', %|+ "" (- 0 123)|
		end

			# a bug from the c impl
		it 'does not reuse the same number buffer' do
			assert_result '1234', %|; = a + "" 12 ; = b + "" 34 : + a b|
		end
	end

	describe 'when the first arg is a number' do
		it 'adds other numbers' do
			assert_result 0, %|+ 0 0|
			assert_result 3, %|+ 1 2|
			assert_result 10, %|+ 4 6|
			assert_result 111, %|+ 112 (- 0 1)|

			assert_result 17, %|+ 4 13|
			assert_result -9, %|+ 4 (- 0 13)|
			assert_result 9, %|+ (- 0 4) 13|
			assert_result -17, %|+ (- 0 4) (- 0 13)|
		end

		it 'converts other values to numbers' do
			assert_result 3, %|+ 1 "2"|
			assert_result 95, %|+ 4 "91"|
			assert_result 10, %|+ 9 TRUE|
			assert_result 9, %|+ 9 FALSE|
			assert_result 9, %|+ 9 NULL|
		end

		it 'can be used to coerce to a number when the lhs is zero' do
			assert_result 12, %|+ 0 "12"|
			assert_result 1, %|+ 0 TRUE|
			assert_result 0, %|+ 0 FALSE|
			assert_result 0, %|+ 0 NULL|
		end

		it 'errors on overflow', when_testing: :overflow do
			fail "todo: overflow (need to get bit length)"
		end
	end

	it 'evaluates arguments in order' do
		assert_result 48, %|+ (= n 45) (- n 42)|
		assert_result 16, %|+ (= n 15) (- n 14)|
		assert_result 14, %|+ (= n 15) (- n 16)|
	end

	it 'only allows a number or string as the first operand', when_testing: :invalid_types do
		refute_runs %|+ TRUE 1|
		refute_runs %|+ FALSE 1|
		refute_runs %|+ NULL 1|
	end

	it 'does not allow a function or variable as any operand', when_testing: :strict_types do
		refute_runs %|; = a 3 : + (BLOCK a) 1|
		refute_runs %|; = a 3 : + 1 (BLOCK a)|
		refute_runs %|+ (BLOCK QUIT 0) 1|
		refute_runs %|+ 1 (BLOCK QUIT 0)|
	end

	it 'requires exactly two arguments', when_testing: :argument_count do
		refute_runs %|+|
		refute_runs %|+ 1|
		assert_runs %|+ 1 1|
	end
end
