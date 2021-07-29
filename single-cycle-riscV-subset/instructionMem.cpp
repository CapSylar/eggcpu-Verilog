#include "instructionMem.h"
#include <string>
#include <iostream>
#include <elfio/elfio.hpp>


instructionMem::instructionMem( const std::string &filename )
{
    ELFIO::elfio reader; 

    if ( !reader.load(filename) )
    {
        std::cerr << "could not load executable\n" ;
        exit(1);
    }

    const auto section = reader.sections[".text"] ; 
    size = section->get_size() ; 


    std::cout << "loaded .text section with size = " << size << " bytes\n";
    const unsigned char *p = ( const unsigned char * ) reader.sections[".text"]->get_data();

    // load .text

    uint32_t temp = 0 ;

    for ( int i = 0 ; i < size ; ++i )
    {
        temp = temp | ( (uint32_t)p[i] << (8*i) ) ;

        if ( i%4 == 3 )
        {
            mem[i/4] = temp;
            temp = 0 ;
        }
    }
}   