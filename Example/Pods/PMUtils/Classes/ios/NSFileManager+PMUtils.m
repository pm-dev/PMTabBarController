//
//  NSFileManager+PMUtils.m
//  
//
//  Created by Peter Meyers on 3/1/14.
//
//

#import "NSFileManager+PMUtils.h"
#import <sys/xattr.h>
#import <sys/stat.h>

@implementation NSFileManager (PMUtils)

- (NSDate *)fileModificationDateForPath:(NSString *)path
{
	NSDictionary	*attrs			= [self attributesOfItemAtPath:path error:NULL];
	NSDate			*modDate		= [attrs fileModificationDate];
	
	return modDate;
}

- (NSString *)xattrStringValueForKey:(NSString *)key atPath:(NSString *)path
{
	size_t					size			= 0;
	char					*str			= NULL;
	NSString				*string			= nil;
	
	size = getxattr([path UTF8String], [key UTF8String], NULL, 0, 0, 0);
	if (size != -1)
	{
		str = malloc(size + 1);
		if (str)
		{
			getxattr([path UTF8String], [key UTF8String], str, size, 0, 0);
			str[size] = '\0';
			
			string = [NSString stringWithUTF8String:str];
			
			free(str);
		}
	}
	
	return string;
}

- (void)setXAttrStringValue:(NSString *)value forKey:(NSString *)key atPath:(NSString *)path
{
	setxattr([path UTF8String], [key UTF8String], [value UTF8String], [value length], 0, 0);
}

/**
 * Only removes files directly underneath the specified directory. This method will *not* recurse into subdirectories.
 */
- (void)shallowRemoveAllFilesInDirectory:(NSString *)path
{
	NSDirectoryEnumerator	*enumerator		= [self enumeratorAtPath:path];
	
	for (NSString *file in enumerator)
	{
		NSString *fullPath		= [path stringByAppendingPathComponent:file];
		struct stat st;
		
		if (stat([fullPath UTF8String], &st) == 0)
		{
			if (!(st.st_mode & S_IFDIR))
				unlink([fullPath UTF8String]);
		}
	}
}


@end
