#include <cstdint>


class dataMem
{   
public:
    dataMem() : mem( new uint32_t[1000] ) {}

    ~dataMem()
    {
        delete mem;
    }

    void writeMem( uint32_t address , uint32_t value )   
    {
        mem[address] = value;
    }

    uint8_t readMem ( uint32_t address ) const
    {
        return mem[address];
    }

private:

    uint32_t *mem = nullptr ;
};