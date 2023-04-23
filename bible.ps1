
$data = Get-Content json/t_asv.json | ConvertFrom-Json

$key_english = Get-Content json/key_english.json | ConvertFrom-Json
# ----------------------------------------------------------------------
class Verse
{
    $id
    $book
    $chapter
    $verse
    $text

    Verse ($id, $book, $chapter, $verse, $text)
    {
        $this.id      = $id      
        $this.book    = $book    
        $this.chapter = $chapter 
        $this.verse   = $verse   
        $this.text    = $text    
    }
}
# ----------------------------------------------------------------------

$bible = foreach ($row in $data.resultset.row)
{
    [Verse]::new($row.field[0], $row.field[1], $row.field[2], $row.field[3], $row.field[4])    
}
# ----------------------------------------------------------------------
exit
# ----------------------------------------------------------------------
$bible | Select-Object -First 10 | ft *
# ----------------------------------------------------------------------
# Verses in Genesis
# ----------------------------------------------------------------------
$bible | Where-Object book -EQ 1 | Measure-Object
# ----------------------------------------------------------------------
# Chapters in Genesis
# ----------------------------------------------------------------------
$bible | Where-Object book -EQ 1 | Group-Object chapter | Measure-Object
# ----------------------------------------------------------------------
# How many verses contain 'sin'
# ----------------------------------------------------------------------
$bible | Where-Object text -Match 'sin' | Measure-Object
# ----------------------------------------------------------------------
# How many verses contain 'hell'
# ----------------------------------------------------------------------
$bible | Where-Object text -Match 'hell' | Measure-Object
# ----------------------------------------------------------------------
# Verses that contain 'hell'
# ----------------------------------------------------------------------
$bible | Where-Object text -Match 'hell' | ft id, book, chapter, verse, @{ Label = 'book'; Expression = { ($key_english.resultset.keys | Where-Object b -eq $_.book).n } }, text
# ----------------------------------------------------------------------
# Verses that contain 'sin'
# ----------------------------------------------------------------------
$bible | Where-Object text -Match 'sin' | ft id, book, chapter, verse, @{ Label = 'book'; Expression = { ($key_english.resultset.keys | Where-Object b -eq $_.book).n } }, text

$bible | Where-Object text -Match 'satan' | ft id, book, chapter, verse, @{ Label = 'book'; Expression = { ($key_english.resultset.keys | Where-Object b -eq $_.book).n } }, text

$bible | Where-Object text -Match 'demon' | ft id, book, chapter, verse, @{ Label = 'book'; Expression = { ($key_english.resultset.keys | Where-Object b -eq $_.book).n } }, text


# ----------------------------------------------------------------------
$book_field      = @{ Label = 'bookn'; Expression = { ($key_english.resultset.keys | Where-Object b -eq $_.book).n } }

$testament_field = @{ Label = 'otnt'; Expression = { ($key_english.resultset.keys | Where-Object b -eq $_.book).t } }

$bible | Where-Object text -Match 'demon' | Select-Object id, book, chapter, verse, $book_field, $testament_field, text | ft *
# ----------------------------------------------------------------------
# How many times does 'demon' occur in the old testament vs new testamant
# ----------------------------------------------------------------------
$bible | Where-Object text -Match 'demon' | Select-Object id, book, chapter, verse, $book_field, $testament_field, text | Group-Object otnt | Select-Object Count, Name

$bible | Where-Object text -Match 'sin' | Select-Object id, book, chapter, verse, $book_field, $testament_field, text | Group-Object otnt | Select-Object Count, Name

$bible | Where-Object text -Match 'hell' | Select-Object id, book, chapter, verse, $book_field, $testament_field, text | Group-Object otnt | Select-Object Count, Name

$bible | Where-Object text -Match 'abraham' | Select-Object id, book, chapter, verse, $book_field, $testament_field, text | Group-Object otnt | Select-Object Count, Name

$bible | Where-Object text -Match 'abraham' | Select-Object id, book, chapter, verse, $book_field, $testament_field, text | ft *
# ----------------------------------------------------------------------
# word frequency table
# ----------------------------------------------------------------------
$result = foreach ($word in 'demon sin hell abraham' -split ' ')
{
    $groups = $bible | Where-Object text -Match $word | Select-Object id, book, chapter, verse, $book_field, $testament_field, text | Group-Object otnt
    
    [PSCustomObject]@{
        word = $word
        OT = ($groups | Where-Object Name -EQ OT).Count
        NT = ($groups | Where-Object Name -EQ NT).Count
    }
}

$result | ft *






$result = foreach ($word in ('god demon sin hell abraham heaven sheol hades' -split ' ') + 'fear not')
{
    $groups = $bible | Where-Object text -Match $word | Select-Object id, book, chapter, verse, $book_field, $testament_field, text | Group-Object otnt
    
    [PSCustomObject]@{
        word = $word
        OT = ($groups | Where-Object Name -EQ OT).Count
        NT = ($groups | Where-Object Name -EQ NT).Count
    }
}

$result | Sort-Object word | ft *
# ----------------------------------------------------------------------
$a = Get-Date

$index = @{}

$prev = ''

foreach ($verse in $bible)
{
    $current = 'book: {0} chapter: {1}' -f $verse.Book, $verse.Chapter
    if ($prev -ne $current)
    {
        $prev = $current
        Write-Host $current -ForegroundColor Yellow
    }

    $words = $verse.text.ToLower() -replace '\.', '' -replace ',', '' -replace ':', '' -replace ';', '' -split ' '

    foreach ($word in $words)
    {
        if ($index[$word] -eq $null)
        {
            $index[$word] = @($verse)
        }
        else
        {
            $index[$word] += $verse
        }        
    }
}

$b = Get-Date

($b - $a).TotalMinutes
# ----------------------------------------------------------------------


# $index | ConvertTo-Json -Depth 100 > index.json

# Compress-Archive .\index.json .\index.json.zip
# ----------------------------------------------------------------------
# index - only verse id
# ----------------------------------------------------------------------

$concise_index = @{}

foreach ($entry in $index.GetEnumerator())
{
    $key = $entry.Name
  
    $concise_index."$key" = $entry.Value | ForEach-Object id
}

$concise_index | ConvertTo-Json -Depth 100 > concise_index.json

Compress-Archive .\concise_index.json .\concise_index.json.zip
# ----------------------------------------------------------------------



# $frequency = 



$a = Get-Date

$frequency = foreach ($entry in $index.GetEnumerator())
{
    [PSCustomObject]@{
        word = $entry.Name
        count = $entry.Value.Count
    }
}

$b = Get-Date

($b - $a).TotalMinutes



$frequency | Sort-Object Count -Descending | Select-Object -First 40 | ft *

$frequency | Where-Object word -NotIn ('the and of to in that a it i is as my me' -split ' ') | Sort-Object Count -Descending | Select-Object -First 40 | ft *


$frequency | Where-Object word -NotIn $stop_words | Sort-Object Count -Descending | Select-Object -First 40 | ft *

$frequency | Where-Object word -NotIn $stop_words | Sort-Object Count -Descending > frequency.txt

# $verse = $bible[0]

# $verse = $bible | Select-Object -First 10 | Where-Object text -Match ',' | Select-Object -First 1

# $verse.text





$stop_words = @"
a
about
above
after
again
against
all
am
an
and
any
are
aren't
as
at
be
because
been
before
being
below
between
both
but
by
can't
cannot
could
couldn't
did
didn't
do
does
doesn't
doing
don't
down
during
each
few
for
from
further
had
hadn't
has
hasn't
have
haven't
having
he
he'd
he'll
he's
her
here
here's
hers
herself
him
himself
his
how
how's
i
i'd
i'll
i'm
i've
if
in
into
is
isn't
it
it's
its
itself
let's
me
more
most
mustn't
my
myself
no
nor
not
of
off
on
once
only
or
other
ought
our
ours
ourselves
out
over
own
same
shan't
she
she'd
she'll
she's
should
shouldn't
so
some
such
than
that
that's
the
their
theirs
them
themselves
then
there
there's
these
they
they'd
they'll
they're
they've
this
those
through
to
too
under
until
up
very
was
wasn't
we
we'd
we'll
we're
we've
were
weren't
what
what's
when
when's
where
where's
which
while
who
who's
whom
why
why's
with
won't
would
wouldn't
you
you'd
you'll
you're
you've
your
yours
yourself
yourselves
"@ -split "`r`n"