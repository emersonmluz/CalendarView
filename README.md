# CalendarView

<img width="427" alt="Captura de Tela 2024-04-10 às 14 32 05" src="https://github.com/emersonmluz/CalendarView/assets/111133275/af73f78a-18b1-4b73-808c-f69092bdb808">

## Como usar

Por trata-se de uma UIView, para adicionar ao projeto basta copiar o código e inserir como uma nova classe, então é só criar uma instância e adiciona-la a hierarquia da sua view.

Você pode usar o CalendarView para exibir apenas o calendário como também pode selecionar dias para alguma finalidade, por padrão ele vem desabilitado para interação, mas você pode habilitar a seleção de dias usando o método **enableInteraction** conforme abaixo: 

**calendarView.enableInteraction = true**

## Seleção de dias

Existe dois tipos de seleção, o default é poder selecionar dias variados conforme a imagem abaixo:

<img width="427" alt="Captura de Tela 2024-04-10 às 14 33 00" src="https://github.com/emersonmluz/CalendarView/assets/111133275/78725261-5f47-4cc8-8185-b7a77c6280a6">

Mas também é possível alterar para dias corridos. Para isso basta informar o número de dias no argumento do método **numberOfContinuousDays**, então ao selecionar um dia irá selecionar a quantidade de dias corridos.

**calendarView.numberOfContinuousDays(15)**

<img width="427" alt="Captura de Tela 2024-04-10 às 14 35 30" src="https://github.com/emersonmluz/CalendarView/assets/111133275/ced1c744-962b-4847-8d50-6a590c6ff2e9">

<img width="427" alt="Captura de Tela 2024-04-10 às 14 35 36" src="https://github.com/emersonmluz/CalendarView/assets/111133275/bbd773fb-35a7-4235-af42-63fe3131a8c7">

<img width="427" alt="Captura de Tela 2024-04-10 às 14 35 43" src="https://github.com/emersonmluz/CalendarView/assets/111133275/9ee7dc96-3101-4035-9637-f7cd73ed212c">

## Alteração de cores

Para customizar as cores acesse a propriedade **colors**:

**calendarView.colors.monthTitle**<br>
**calendarView.colors.headerBackground**<br>
**calendarView.colors.weekTitles**<br>
**calendarView.colors.weekBackground**<br>
**calendarView.colors.sundayColor**<br>
**calendarView.colors.daySelected**<br>
**calendarView.colors.daySelectedBackground**<br>
**calendarView.colors.daysIntervalBackground**<br>
**calendarView.colors.calendarBackground**<br>
**calendarView.colors.daysOfMonth**<br>
**calendarView.colors.otherDays**<br>

<img width="427" alt="Captura de Tela 2024-04-10 às 14 55 29" src="https://github.com/emersonmluz/CalendarView/assets/111133275/ca21a21b-4332-4996-983b-ebb287af59ec">
