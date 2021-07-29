#include <cstdint>


class dataMem
{   
public:
    void writeMem( uint32_t address , uint32_t value )   
    {
        mem[address >> 2] = value;
    }

    uint8_t readMem ( uint32_t address ) const
    {
        return mem[address >> 2];
    }

private:
    uint32_t mem[1000] = {0} ;
};