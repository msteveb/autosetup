all: test1 test2 test3 test4 test5 test6 test7 test8

test1:
	@./configure >$@.out
	@diff -u $@.exp $@.out
	@rm $@.out
	@echo options $@ OK

test2:
	@./configure --bool --bool0 --bool1 >$@.out
	@diff -u $@.exp $@.out
	@rm $@.out
	@echo options $@ OK

test3:
	@./configure --str0=a --str1=b --str2=c --str3=d --str4=e >$@.out
	@diff -u $@.exp $@.out
	@rm $@.out
	@echo options $@ OK

test4:
	@./configure --ostr0=a --ostr1=b --ostr2=c --ostr3=d --ostr4=e >$@.out
	@diff -u $@.exp $@.out
	@rm $@.out
	@echo options $@ OK

test5:
	@./configure --str1=a --str1=b --ostr1=c --ostr1=d >$@.out
	@diff -u $@.exp $@.out
	@rm $@.out
	@echo options $@ OK

test6:
	@./configure --str2 --ostr2 >$@.out
	@diff -u $@.exp $@.out
	@rm $@.out
	@echo options $@ OK

test7:
	@./configure --str1 >$@.out 2>&1 || true
	@diff -u $@.exp $@.out
	@rm $@.out
	@echo options $@ OK

test8:
	@./configure --str4 >$@.out
	@diff -u $@.exp $@.out
	@rm $@.out
	@echo options $@ OK
