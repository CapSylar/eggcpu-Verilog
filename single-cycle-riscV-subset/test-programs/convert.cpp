#include <string>
#include <iostream>
#include <elfio/elfio.hpp>
#include <iomanip>


int main ( int argc , char **argv  )
{
    if ( argc < 3 )
    {
        std::cerr << "expected 2 arguments\n" ;
        exit(1);
    }

    ELFIO::elfio reader; 

    if ( !reader.load(argv[1]) )
    {
        std::cerr << "could not load executable\n" ;
        exit(1);
    }

    // open file  at argv[3]

    std::ofstream file;
    file.open( argv[2] );
    
    if ( file.fail() )
    {
        std::cerr << "could not open mem file for writing\n" ;
        exit(1);
    }

    const auto section = reader.sections[".text"] ; 
    const auto size = section->get_size() ;


    std::cout << "loaded .text section with size = " << size << " bytes\n";
    const auto *p = ( const unsigned char * ) reader.sections[".text"]->get_data();

    // load .text section

    uint32_t temp = 0 ;

    auto width = std::setw(8);
    auto fill = std::setfill('0');

    for ( int i = 0 ; i < size ; ++i )
    {
        temp = temp | ( (uint32_t)p[i] << (8*i) ) ;

        if ( i%4 == 3 )
        {
            file << std::hex << width << fill << temp << '\n' ;
            temp = 0 ;
        }
    }

    file.close();
}