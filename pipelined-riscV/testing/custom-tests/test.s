.text

#simple test, ok= exit code 2

li x1,1000
li x2,2000

li x6,4
call error

li x2,1000

beq x1,x2,error

li x1,0
li x2,0





error:
	li x4,29
	li x5,78
	
