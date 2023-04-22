
cd C:\Users\dharm\bible_databases

$data = Get-Content C:\Users\dharm\bible_databases\json\t_asv.json | ConvertFrom-Json



$key_english = Get-Content C:\Users\dharm\bible_databases\json\key_english.json | ConvertFrom-Json



$data.resultset.row | Select-Object -First 10

$data.resultset.row.Count


$data.resultset.row[0]


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

$bible = foreach ($row in $data.resultset.row)
{
    [Verse]::new($row.field[0], $row.field[1], $row.field[2], $row.field[3], $row.field[4])    
}

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