#! /usr/bin/perl
use strict;
use warnings;

#Opens the file to be converted
#INPUT: FILE
#OUTPUT: NONE
#RETURNS: Pointer to text Array
sub openFile
{
	print "What file do you wish to open?\n##";
	chomp (my $fileToOpen = <STDIN>);
	#Opens the dictionary file
	open FILE, $fileToOpen or die $!;
	#Saves the file to an array
	my @source = <FILE>;
	#Returns a pointer to the array
	return \@source;
}

#Saves the converted output to the destination file.
#INPUT: FILE
#OUTPUT: Saves file to disk 
#RETURNS NONE
sub saveFile
{
	print "What file do you wish to save the converted files to?\n##";
	chomp (my $fileToSave = <STDIN>);
	my $fileOut = shift;
	my @fileOut = @$fileOut;
	if ( -e $fileToSave)
	{
		die "File Exists!\n"
	}
	open (FILE, ">> $fileToSave");
	foreach (@fileOut)
	{
		print FILE "$_\n";
	}
	close (FILE);
}

#Adds way to words beginning with a vowel sound.
#INPUT: lowercased word
#OUTPUT: NONE
#RETURNS: word+way string
sub alterVowelStarts
{
	my $word = shift;
	
	$word = $word."way";
	return $word;
}

#Finds the position of the first vowel in a word and returns it.
#INPUT: Word
#OUTPUT: NONE
#RETURNS: Vowel Position 
sub findFirstVowel
{
	my $wordIn = shift;
	my @word = split ('', $wordIn);
	my $firstVowelCounter = 0;
	foreach (@word)
	{
		if ($_ =~ m/[^aeiou]/)
		{
			$firstVowelCounter++;
		}
		else
		{
			last;
		}
	}
	return $firstVowelCounter;
}

#Alter words that start with a consonant after they have been lowercased.
#INPUT: Word
#OUTPUT: NONE
#RETURNS altered vowel.
sub alterConsStarts
{
	my $wordIn = shift;
	my $wordOut = "";
	my $shuffle = "";
	my @word = split ('',$wordIn);
	my $firstVowel = findFirstVowel($wordIn) - 1;
	for (my $i = 0; $i <= $firstVowel; $i++)
	{
		$shuffle = $shuffle.$word[$i];
		$word[$i] = '';
	}
	$wordIn = join ('', @word);
	$wordOut = $wordIn.$shuffle."ay";
	return $wordOut;
}

# Removes beginning or ending punctuation
# INPUT: Word
# OUTPUT: NONE
# RETURNS: Reference to array containing punctuation and word without the leading punctuation.
sub removeFirstPunct
{
	my $wordIn = shift;
 	my $whichFlag = shift;
	my $wordOut = "";
	my $chars = "";
	my @word = split ('', $wordIn);
	my $wordCounter = 0;
	my @returns = ();
		for (@word)
		{
			if ($_ =~ m/^[^[:alnum:]]/)
			{
				$chars = $chars.$word[$wordCounter];
				$word[$wordCounter] = '';
			}
			else
			{
				last;
			}
			$wordCounter++;
		}
	$wordOut = join('',@word);
	push (@returns, $chars);
	push (@returns, $wordOut);
	return \@returns;
}

#Removes Trailing Punctuation from word
#INPUT: word
#OUTPUT: NONE
#RETURNS: Reference to array containing punctuation and word without the trailing punctuation.
sub removeLastPunct
{
        my $wordIn = shift;
        my $whichFlag = shift;
        my $wordOut = "";
        my $chars = "";
        my @word = split ('', $wordIn);
        my $wordCounter = 0;
        my @returns = ();
                for (@word)
                {
			if ($_ =~ m/^[[a-zA-Z]]/)
			{
			}
                        elsif ($_ =~ m/^[^a-zA-Z]/)
                        {
                                $chars = $chars.$word[$wordCounter];
                                $word[$wordCounter] = '';
                        }
			$wordCounter++;
                }
        $wordOut = join('',@word);
        push (@returns, $chars);
        push (@returns, $wordOut);
        return \@returns;
}

#Makes the word all lowercase, and returns both the lowercased word, and a flag indicating wether only the first char, or all chars are capitalized
#INPUT: Word
#OUTPUT: NONE
#RETURNS: Capitalization Flag, and lowercased word.
sub lcCaps
{
	my $wordIn = shift;
	my $capWord = uc($wordIn);
	my $firstChar = substr($wordIn, 0, 1);
	my $wordOut = lc($wordIn);
	my $flag = 0;
	if ($firstChar =~ m/[A-Z]/)
	{
		$flag = 1;
	}
	if ($wordIn eq $capWord)
	{
		$flag = 2;
	}
	my @returnVals = ($flag, $wordOut);
	return \@returnVals;
}

#Main Subroutine which handles Word Transformation, calls other word transformation\
#INPUT: Word
#OUTPUT: NONE
#RETURNS: Altered Word
sub alterWord
{
	my $wordIn = shift;
	my @word = split ('',$wordIn);
	my $wordLen = length $wordIn;
	my $firstChars = "";
	my $firstLetter = "";
	my $capFlag = 0;
	my $lastChars = "";
	my $wordOut = "";
	my $wordMangle = "";
#Remove Starting Punctuation
	my $rFromSub = removeFirstPunct($wordIn);
	my @inFromSub = @$rFromSub;
	$firstChars = $inFromSub[0];
	$wordIn = $inFromSub[1];
#Remove Ending Punctuation
	$rFromSub = removeLastPunct($wordIn);
	@inFromSub = @$rFromSub;
	$lastChars = $inFromSub[0];
	$wordIn = $inFromSub[1];
#Determine capitalization. amd reomove capitalization
	my $capResults = lcCaps($wordIn);
	my @lcCap = @$capResults;
	$capFlag = $lcCap[0];
	$wordIn = $lcCap[1];
##Determine if the word starts with aeiou
	$firstLetter = substr ($wordIn, 0, 1);
	if ($firstLetter =~ m/(a|e|i|o|u)/)
	{
		$wordIn = alterVowelStarts($wordIn);
	}
	elsif ($firstLetter =~ m/[^aeiou]/)
	{
		$wordIn = alterConsStarts($wordIn);
	}
	else
	{
		$wordIn = $wordIn;
	}
#Restore Capitalizations
	if ($capFlag == 1)
	{
		$wordIn = ucfirst($wordIn);
	}
	elsif ($capFlag == 2)
	{
		$wordIn = uc($wordIn);
	}
	$wordOut = $firstChars.$wordIn.$lastChars;
	return $wordOut;
}

#Splits a line of the file into words.  It splits by spaces, so it leaves punctuation with the word it is next to.
#INPUT: Source Array
#OUTPUT: NONE
#RETURNS: Altered Line as a string
sub splitLine
{
	my $source = shift;
	my $word = "";
	chomp($source);
	my @destination = ();
	my $destiny = "";
	my @sourceArray = split(' ',$source);
	foreach (@sourceArray)
	{
		$word = alterWord($_);
		push (@destination, $word);
	}
	$destiny = join (' ',@destination);
	return $destiny;
}

#Runs the operation to convert text to Pig Latin
#INPUT: NONE
#OUTPUT: NONE
#RETURNS: NONE
sub main
{
	my $sourcePTR = openFile();
	my @source = @$sourcePTR;
	my $lineCounter = 0;
	my @alteredLines = ();
	foreach (@source)
	{
		$alteredLines[$lineCounter] = splitLine($_);
		$lineCounter++;
	}
	saveFile(\@alteredLines);
}

main();
