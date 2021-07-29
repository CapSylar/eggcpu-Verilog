#include <cstdint>
#include <string>

class instructionMem
{
public:
    instructionMem( const std::string &filename ) ; 

    uint32_t readMem ( uint32_t address ) const
    {
        address >>= 2;
        if ( address < size )
            return mem[address]; 
        return 0xFFFFFFFF ;
    }

private:
    // lw , sw
    uint32_t mem[1000] ;
    size_t size = 0 ;
};