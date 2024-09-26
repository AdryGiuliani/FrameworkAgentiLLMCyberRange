# Un framework ad agenti LLM per la generazione di scenari Cyber Range

### Tesi di laurea triennale in Ingegneria informatica presso Università della Calabria (UNICAL).

![Framework overview](/diagrammaLegendTopLEft.png)

I contributi principali del presente lavoro di tesi sono i seguenti:

1.Automazione della generazione di scenari
>La costruzione di infrastrutture per cyber range richiede molti passaggi di cui gran parte ripetitivi;
>tramite il sistema proposto le operazioni di generazione macchine virtuali e installazione di software su quest'ultime sono implementate tramite file di configurazione pronti all'uso;
>utile soprattutto in contesti formativi, dove può rivelarsi necessaria la generazione di molteplici infrastrutture.

2.Democratizzazione della creazione di cyber range
>Il beneficio principale ottenuto dall'implementazione di richieste in linguaggio naturale è l'astrazione dalla scrittura effettiva dei file di configurazione; sarà necessaria unicamente la formulazione di una richiesta, contenente la descrizione più o meno dettagliata del cyber range da generare per ottenere immediatamente i file necessari al deployment dello stesso.

3.Creatività e realismo degli scenari
>Il sistema sfrutta le capacità generative degli ultimi modelli LLM in modo da costruire senza sforzo scenari variegati e completi, oltre a fornire spunti creativi all'utilizzatore per la creazione di scenari quanto più verosimili possibile; tale aspetto, come già accennato, influenza fortemente l'efficacia dei cyber range, limitando l'impiego di scenari ripetitivi e banali.

4.Modularità della generazione
>L'approccio utilizzato rende il sistema "future-proof", permettendo di adeguare la generazione alle ultime versioni di plugin terraform ed a diversi hypervisor, oltre alla possibilità, grazie al supporto offerto dalle librerie LangChain, di intercambiare facilmente i modelli LLM assegnati alle task di creazione risorse e generazione file, in modo da poter approfittare di future riduzioni di costi ed incrementi alla qualità di generazione offerti di eventuali modelli futuri.


Per l'utilizzo è necessario:
-definire il file provider.tf come suggerito
-predisporre come variabile ENV la propria api key openai
