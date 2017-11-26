all: test1 test2 test3 test4 test5

test1:
	@./configure >$@.out
	@diff $@.exp $@.out
	@rm $@.out
	@echo options $@ OK

test2:
	@./configure --bool --bool0 --bool1 >$@.out
	@diff $@.exp $@.out
	@rm $@.out
	@echo options $@ OK

test3:
	@./configure --str0=a --str1=b --str2=c --str3=d --str4=e >$@.out
	@diff $@.exp $@.out
	@rm $@.out
	@echo options $@ OK

test4:
	@./configure --ostr0=a --ostr1=b --ostr2=c --ostr3=d --ostr4=e >$@.out
	@diff $@.exp $@.out
	@rm $@.out
	@echo options $@ OK

test5:
	@./configure --str1=a --str1=b --ostr1=c --ostr1=d >$@.out
	@diff $@.exp $@.out
	@rm $@.out
	@echo options $@ OK
