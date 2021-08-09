.text

#simple test, ok= exit code 2

li x1,1000
sw x1, 0(x0)
lw x2, 0(x0)
add x3,x2,x1


#     li x2,55
#     sw x2, 8(x1)

#     lw x3, 8(x1)

#     bne x2,x3,error
#     li x1,5
#     add x3,x1,x2
#     li x4,12
#     beq x3,x4,end
#     li x5,100

#     # end of tests
#     li x1,2
#     sw x1, 4(x0) 

# end:
#     li x2, 1
#     sw x2, 0(x0)
#     # simulation stops here ***********

# error:
#     li x2,1
#     sw x2, 4(x0)
#     beq x0,x0,end
