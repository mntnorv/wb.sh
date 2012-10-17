#include <iostream>
#include <string>

using namespace std;

int main(int argc, const char* argv[])
{
	if (argc > 1)
	{
		string code = argv[1];
		string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
		int k = 0;
		int n = 0;

		do
		{
			int a, b, c, d = 0;
			int f, g, h, i = 0;

			a = chars.find(code[k++]);
			b = chars.find(code[k++]);
			c = chars.find(code[k++]);
			d = chars.find(code[k++]);

			f = a << 18 | b << 12 | c << 6 | d;
			g = f >> 16 & 255;
			h = f >> 8 & 255;
			i = f & 255;

			if (c==64)
				cout << (char)g;
			else if (d==64)
				cout << (char)g << (char)h;
			else
				cout << (char)g << (char)h << (char)i;
		} while (k < code.length());
	}

	return 0;
}