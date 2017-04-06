void foo(int x)
{
	switch (x) {
		case 0:
			{
				x++;
				
				#ifdef ENABLE_A
				x--;
				#endif
			}
			break;
		case 1:
		case 2:
			{
				x = x + 2;

				#ifdef ENABLE_A
				x = x + 3;
				#endif
			}
			break;
			case 3:
			#ifdef ENABLE_B
			{
				x = x - 10;
			}
			break;
			#endif
		case 4:
			x = x + 9;
	}
}
