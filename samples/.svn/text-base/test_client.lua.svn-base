require('osc.client')

VAR1 = {
	'#bundle',
	os.time(),
	{
            '/play',
            's',
            'on',
            'i',
            40,
            'i',
            10,
            'i',
            0,
            'i',
            20,
            'i',
            100,
            'i',
            100,
            'i',
            10,
            'i',
            0,
            'i',
            1
	}
}

VAR2 = {
	'#bundle',
	os.time(),
	{
            '/play',
            's',
            'on',
            'i',
            40,
            'f',
            10.1,
            'i',
            0,
            'i',
            20,
            'i',
            100,
            'i',
            100,
            'i',
            10,
            'i',
            0,
            'i',
            1
	}
}



local osc = osc.client.new{host = 'localhost', port = 7777} --57120}

print (VAR2[2])
        
osc:send(VAR2)

