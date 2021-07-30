.text

#simple test, ok=0 error=1


    li x2,100
    li x3,100
    li x4,100
    li x5,100
    li x6,100
    li x7,100

    

# test:
#     la x1,0
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
#     sw x0, 4(x0) 

end:
    li x2, 1
    # sw x2, 4(x1) # exit code 1 try it
    sw x2, 0(x0)
    # simulation stops here ***********

error:
    li x2,1
    sw x2, 4(x0)
    beq x0,x0,end
