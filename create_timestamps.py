import os
import argparse
import re

parser = argparse.ArgumentParser(description='Simple application to create sequential timestamps for images in a directory (Useful for ORB SLAM). Output file name is determined by input')
parser.add_argument('-i', action='store', default = './', dest='input', help='Image directory (Default: ./)')
parser.add_argument('-o', action='store', default='./', dest='output', help='Output location without filename (Default: ./)')

def atoi(text):
	return int(text) if text.isdigit() else text

def natural_keys(text):
	return [atoi(c) for c in re.split('(\d+)',text)]

def main():
	try:
		args = parser.parse_args()
		
		if type(args.input) is not str:
			raise Exception("Error: Input Directory argument (-i) should be a string")
		if type(args.output) is not str:
			raise Exception("Error: Output Directory argument (-o) should be a string")
			
		if args.output[-4:len(args.output)] == '.txt':
			raise Exception("Error: Output Directory argument should not include file name. This is determined automatically.")

		oname = args.input.split('/')[-2::][0]
		output_target = "%s%s_ts.txt" % (args.output, oname)

		with open(output_target, "w") as f:
			for img_name in sorted(os.listdir(args.input), key=natural_keys):
				f.write("%s\n" % img_name[:-4])
	except Exception as e:
		print e
		

if __name__ == '__main__':
	main()
