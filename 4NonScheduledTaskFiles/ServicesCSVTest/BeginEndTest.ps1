function TestEnd
{
    [CmdletBinding()]
    param ()

    begin
    {
        $Error.Clear()
        "In begin block"
        
        0/0

        if ($Error.Count -gt 0)
        {
            continue
        }
    }

    process
    {
        "In process block"
    }

    end
    {
        "In end block"
    }
}

TestEnd