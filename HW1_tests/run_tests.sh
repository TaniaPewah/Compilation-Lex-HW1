#!/bin/bash
flex hw1.lex
gcc -ll lex.yy.c
for f in *.in
do
	NAME="${f%.*}"
	echo "Running ${NAME}..."
	./a.out <$NAME.in >& $NAME.res
	diff $NAME.res $NAME.out
	if [ $? -eq 0 ]; then
		echo "Passed!"
    else
		echo "ERROR"
		break
	fi
done
echo "END OF TEST"