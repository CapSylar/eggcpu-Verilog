template<class MODULE>
class TestBench
{
public:
	unsigned long m_tickcount = 0;
	MODULE	*m_core = nullptr ;
    VerilatedVcdC* m_trace = nullptr;

	TestBench()
    {
		m_core = new MODULE;
        // for tracing with vcd file
        Verilated::traceEverOn(true);
	}

	virtual ~TestBench()
    {
		delete m_core;
	}

	// virtual void	reset(void) {
	// 	m_core->i_reset = 1;
	// 	// Make sure any inheritance gets applied
	// 	this->tick();
	// 	m_core->i_reset = 0;
	// }

	virtual void tick()
    {
		// Increment our own internal time reference
		m_tickcount++;

		// Make sure any combinatorial logic depending upon
		// inputs that may have changed before we called tick()
		// has settled before the rising edge of the clock.
		m_core->clk = 0;
		m_core->eval();

        if(m_trace)
            m_trace->dump(10*m_tickcount-2);

		// Toggle the clock

		// Rising edge
		m_core->clk = 1;
		m_core->eval();

        if(m_trace)
            m_trace->dump(10*m_tickcount);

		// Falling edge
		m_core->clk = 0;
		m_core->eval();

        if(m_trace)
            m_trace->dump(10*m_tickcount+5);
	}

    virtual	void opentrace(const char *vcdname)
    {
		if (!m_trace)
        {
			m_trace = new VerilatedVcdC;
			m_core->trace(m_trace, 99);
			m_trace->open(vcdname);
		}
	}

	// Close a trace file
	virtual void close()
    {
		if (m_trace)
        {
			m_trace->close();
			m_trace = nullptr;
		}
	}

	virtual bool done() { return (Verilated::gotFinish()); }
};