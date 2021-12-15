Function Start-HSCSpeech {
    param(
       [Parameter (Mandatory=$true)]
       [string]$Phrase = "Hi mom, how are you doing?"
    )
          Add-Type -AssemblyName System.Speech 
          $Speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
          
          $Speak.Speak($Phrase)    
}