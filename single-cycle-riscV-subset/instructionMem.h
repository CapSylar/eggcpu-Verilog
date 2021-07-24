#include <cstdint>

class instructionMem
{
public:
    instructionMem() = default;
    
    uint32_t readMem ( uint32_t address ) const
    {
        if ( address < 2 )
            return mem[address]; 
        return 0xFFFFFFFF ;
    }

private:
    // lw , sw
    uint32_t mem[5] = { 0b11100011100000001010000000000011 , 0b01100011100000000000011000100011 };
};