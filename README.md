# Enterprise-Challenge---Sprint-4---Reply

# FIAP - Inteligência artificial e data science

<p align="center">
<a href= "https://www.fiap.com.br/"><img src="assets/logo-fiap.png" alt="FIAP - Faculdade de Informática e Admnistração Paulista" border="0" width=40% height=40%></a>
</p>

<br>

# Nome do projeto
Enterprise Challenge - Sprint 4 - Reply

## Nome do grupo
39

## 👨‍🎓 Integrantes: 
- <a href="https://www.linkedin.com/company/inova-fusca">Guilherme Campos Hermanowski </a>
- <a href="https://www.linkedin.com/company/inova-fusca">Gabriel Viel </a>
- <a href="https://www.linkedin.com/company/inova-fusca"> Matheus Alboredo Soares</a> 
- <a href="https://www.linkedin.com/company/inova-fusca">Jonathan Willian Luft </a>

## 👩‍🏫 Professores:
### Tutor(a) 
- <a href="https://www.linkedin.com/company/inova-fusca">Leonardo Ruiz Orabona</a>
### Coordenador(a)
- <a href="https://www.linkedin.com/company/inova-fusca">ANDRÉ GODOI CHIOVATO</a>

# ABAIXO SEGUE O MERGE DE TODOS AS EXPLICAÇÕES DAS ETAPAS PASSADAS

Adicionamos uma interaface gráfica com streamlit que contempla uma vizualição ampla dos dados, também 

## 📜 Justificativa do problema e descrição da solução proposta

<br>

Em cenários de produção onde há um grande número de maquinário atuando, é rotineiro que diferentes tipos de erros e falhas que acabem por gerar prejuízos e atrapalhar no andamento da produção aconteçam.
Mas e se esses prejuízos e paradas na produção pudessem ser previstos, e assim, antecipadamente evitados, dessa otimizando os processos de melhorando o fluxo de trabalho da empresa? É a partir dessa visão de negócio que surge nosso projeto. 
</p>
Com foco no monitoramento e previsão de falhas em equipamentos de produção, utilizamos de sensores de temperatura, vibração, umidade e volume de produção, somado a uma arquitetura baseada em serviços AWS, para detecção de falhas antes que elas ocorram, permitindo que alertas sejam gerados e o erro evitado antes de sua incidência.


## 🔧 Componentes
**Definição das tecnologias que serão utilizadas (linguagens de programação, bibliotecas de IA, serviços de nuvem, banco de dados etc.):**

**AWS IoT Core:**

  -	***Definição:*** Permite conectar dispositivos físicos (como ESP32) à nuvem de forma segura, confiável e escalável.<br>
  -	***Linguagem:*** MQTT, HTTP, TLS (via certificados).<br>
  -	***Propósito:*** Receber os dados dos sensores do ambiente físico (temperatura, vibração, entre outras coletas) e encaminhá-los para o RDS.<br>
  -	***Funcionamento:*** O dispositivo publica mensagens para um tópico MQTT, o IoT Core aplica regras de roteamento para enviar esses dados diretamente para RDS.<br>

**Amazon RDS:**

  -	***Definição:*** Banco de dados relacional, sem a necessidade de um EC2 e diminuindo atribuições como manutenção, configuração e atualizações de sistema Operacional, Redes ou Backup por exemplo.<br>
  -	***Linguagem:*** SQL<br>
  -	***Proposito:*** Armazenar os dados bruto do sensor, para garantir dados originais e também quaisquer logs adicionais pela equipe de IA (resultados de treinamentos por exemplo) ou estrutura relacional nova para atender escalabilidade da arquitetura de banco.<br>

**Armazenamento S3 + Lake:**

  -	***Definição:*** Armazenamento (S3) em nuvem e governança e controle de acesso sobre o armazenament (Lake Formation).<br>
  -	***Integração:*** Através de replicação de dados do RDS e Lambda.<br>
  -	***Propósito:*** Ter um repositório sem impactar em ambiente produtivo (RDS) e também possibilitando uma futura fonte de dados para construção de Dashboards, além de servir de fonte de dados para a IA.<br>
  -	***Funcionamento:*** Assim que realizado um UPLOAD mapeado no S3, é diparado um gatilho para o Lambda acessar e dar inicio as etapas referentes aos dados para a IA.<br>

**Amazon Lambda:**

  -	***Definição:*** Permitir executar código em resposta a eventos.<br>
  -	***Linguagem:*** Python.<br>
  -	***Propósito:*** Realizar o pré processamento deles disparados pelo S3 e realizar a carga para o Amazon SageMaker, além também de servir para possível carga de dados no banco produtivo, referente a algum log a ser registrado no RDS.<br>
  -	***Funcionamento:*** Disparado pelo S3 ou para carga de dados no RDS.(Em resumo uma ferramenta da AWS para integração de fluxos).<br>

**Amazon SageMaker:**

  -	***Definição:***  Plataforma de machine learning gerenciada para criar, treinar, implantar e monitorar modelos de aprendizado de máquina.<br>
  -	***Linguagem:*** TensorFlow, R, Pandas e Numpy.<br>
  -	***Integração:*** É acionado após o Lambda receber e fazer o pré processamento desses dados do S3.<br>
  -	***Propósito:*** Processar os dados recebidos e realizar inferência com base nos modelos treinados, como detectar os padrões dos logs recebidos do sensor ESP32 e poder gerar uma análise preditiva.<br>
  -	***Funcionamento:*** Recebe os dados do Lambda, executa a inferência com o modelo implantado e retorna a resposta, podendo registrar algum resultado no RDS (através do Lambda), ou disparando notificações para os usuários responsáveis sobre o equipamento monitorado em especifico daquele sensor.<br>

**AWS Step Functions:**

  -	***Definição:*** Coordenar a execução sequencial e condicional de vários serviços, para fluxos mais longos ou lógica mais complexa.<br>
  -	***Linguagem:*** Podemos criar o Fluxo visualmente pelo console da AWS ou por exemplo chamar uma função Lambda escrita em Python.<br>
  -	***Propósito:*** Organizar fluxos complexos em etapas visuais com controle de erro, espera, decisão e paralelismo.<br>

**Amazon CloudWatch:**

  -	***Definição:*** Monitoramento e observação de métricas, logs e alarmes de recursos da AWS.<br>
  -	***Integração:*** Coleta logs e métricas do Lambda, monitora uso do SageMaker, e pode disparar  SNS ou outra função Lambda com base em condições.<br>
  -	***Propósito:*** Acompanhar o comportamento do sistema e criar automações baseadas em falhas ou condições predefinidas.<br>
  -	***Funcionamento:*** Analisa as métricas ou logs, acompanha os processos e disparar alertas via SNS ou outras funções de recursos.<br>

**Amazon SNS (Simple Notification Service):**

  -	***Definição:*** Envio de alertas e notificações por e-mail, SMS ou outras aplicações.<br>
  -	***Propósito :*** Integrado com o Lambda ou diretamente com CloudWatch. Pode ser acionado com base nos resultados da IA, pela observação do CloudWatch em resposta a um evento, no nosso caso o acionamento em decorrência da identificação de problemas pela análise preditiva da IA e notificar  o responsável técnico pelo tipo de equipamento coletado pelo sensor que acusou o possível problema antes de ocorrer a parada em produção.<br>
  -	***Funcionamento:*** Se a inferência do SageMaker indicar uma condição anormal, o Lambda ou Step Function publica uma mensagem no SNS que é entregue ao responsável via email, sms ou por alguma aplicação.<br>


## 📁 Arquitetura e Pipeline

![Pipeline AWS](https://github.com/user-attachments/assets/5eab299f-b2ad-4ea4-81e9-da8b4054551b)


## 🔧 Funcionamento

O sistema utiliza uma arquitetura de monitoramento inteligente na AWS, integrando sensores físicos, banco de dados, machine learning e notificações automatizadas. O ESP32 envia dados de sensores (volume de produção, temperatura, umidade e vibração) via MQTT para o AWS IoT Core, com comunicação segura por TLS e autenticação por certificados. Esses dados são roteados para uma função AWS Lambda, que grava as informações no Amazon RDS, um banco relacional gerenciado e seguro.

Para viabilizar análises futuras e separar a carga operacional da base produtiva, os dados do RDS são exportados para o Amazon S3. Esse armazenamento forma o Data Lake, com controle de acesso gerenciado pelo AWS Lake Formation. A chegada de novos dados no S3 aciona automaticamente uma função AWS Lambda (via gatilho), que faz o pré-processamento utilizando Python e bibliotecas como pandas e boto3, e em seguida envia os dados ao Amazon SageMaker.

O Amazon SageMaker realiza a inferência com modelos desenvolvidos em Python, utilizando bibliotecas como TensorFlow, scikit-learn, numpy e pandas, para detectar padrões e antecipar possíveis falhas operacionais. Os resultados podem ser armazenados no RDS ou encaminhados a outras funções Lambda para tomada de decisão.

Workflows mais complexos e decisões condicionais são coordenados por AWS Step Functions, que orquestram a sequência de chamadas e ações de forma estruturada.

Para observabilidade, o Amazon CloudWatch coleta métricas e logs de todos os serviços envolvidos, como Lambda, SageMaker e Step Functions. Alarmes podem ser configurados para detectar falhas, tempos de resposta anormais ou comportamentos críticos, acionando o Amazon SNS para notificar os responsáveis via e-mail, SMS ou integração com sistemas externos.

## 👨‍🎓 Divisão de responsabilidades:
- Arquitetura (Pipeline e estrutura de features na AWS) : <a href="https://www.linkedin.com/company/inova-fusca">Gabriel Viel </a>
- Coleta de dados: <a href="https://www.linkedin.com/company/inova-fusca">Jonathan Willian Luft </a> e <a href="https://www.linkedin.com/company/inova-fusca">Guilherme  Campos Hermanowski </a>
- Banco de Dados: <a href="https://www.linkedin.com/company/inova-fusca">Gabriel Viel </a>
- Treinamento de IA: <a href="https://www.linkedin.com/company/inova-fusca"> Matheus Alboredo Soares</a> 
- Integração de Features: <a href="https://www.linkedin.com/company/inova-fusca">Gabriel Viel </a>, <a href="https://www.linkedin.com/company/inova-fusca"> Matheus Alboredo Soares</a>, <a href="https://www.linkedin.com/company/inova-fusca">Jonathan Willian Luft </a> e <a href="https://www.linkedin.com/company/inova-fusca">Guilherme  Campos Hermanowski </a>


## 🔧 Componentes
**Definição das tecnologias que serão utilizadas (linguagens de programação, sensores, plataformas de simulação, etc.):**

**Wokwi:**

  -	***Definição:*** Plataforma online para simulação de algoritmos para sensores e dispositivos físicos.<br>
  -	***Linguagem:*** C++.<br>
  -	***Propósito:*** O wokwi vem como uma plataforma para viabilizar os testes em sensores físicos, permitindo que seu usuário desenvolva códigos e organize sensores de maneira simulada antes de aplicar na prática, dessa forma evitando erros e danos aos dispositivos físicos.<br>
  -	***Funcionamento:*** permite criar, programar e testar projetos diretamente no navegador através de sesores simulados, assim, descartando a necessidade de hardware físico.<br>

**Sensores:**

  -	***DHT22:*** .<br>
    - ****Função****: Responsável por medir temperatura (°C) e umidade relativa do ar (%).<br>
    - ****Funcionamento****: No código, os valores são simulados usando a função random() para gerar dados entre: Temperatura: 20,0 °C a 90,0 °C e Umidade: 9,0% a 90,0%.<br>
  -	***MPU6050*** .<br>
    - ****Função****: Usado para medir aceleração e rotação, mas nesse caso foi adaptado para medir a vibração do maquinário em Hz.<br>
    - ****Funcionamento****: A vibração (Hz) também é simulada entre 20,0 Hz e 80,0 Hz usando random().<br>
  -	***BOTÃO:*** <br>
    - ****Função****: Simula um botão conectado ao pino D12, usando INPUT_PULLUP.<br>
    - ****Funcionamento****: Como não tinhamos um sensor de infravermelho para poder detectar a passagem de produtos e assim calcular de uma melhor forma a quantidade produzida, elaboramos a variável valorBotao parea percorrer ciclicamente os valores de 0 a 3, representando a seleção de um entre quatro produtos.<br>


## 🔧 Funcionamento

Este projeto implementa um sistema de monitoramento utilizando a placa ESP32, um sensor de temperatura e umidade DHT22, um sensor inercial MPU6050 e um botão físico. Os dados são simulados para testes em ambiente virtual (Wokwi) e exibidos no formato CSV pelo monitor serial, possibilitando futura exportação ou análise.

### Funcionamento dos sensores:

O sistema realiza a leitura simulada de três sensores a cada 5 segundos:

- ***Temperatura:*** Valor aleatório entre 20.0 e 90.0 °C

- ***Umidade:*** Valor aleatório entre 9.0 e 90.0 %

- ***Vibração:*** Valor entre 20.0 e 80.0 Hz

- ***Produtos:*** Contador cíclico de 0 a 3 (simulando estados de operação)

Esses dados são impressos no monitor serial no formato CSV, com o seguinte cabeçalho:

*Timestamp,Temperatura(°C),Umidade(%),Vibracao(Hz),Produtos*

*Exemplo de saída:* 12,34.2,65.1,52.4,1

**Nota:** Os sensores reais estão conectados, mas os valores são gerados aleatoriamente para simulação.

### Lógica do Botão
- O botão está conectado com INPUT_PULLUP.<br>
- Cada ciclo de leitura incrementa o valor valorBotao de 0 a 3, reiniciando após 3.<br>
- Isso simula o avanço de um estado de produção ou operação.<br>

Aqui esta uma imagens para ilustrar a explicação de como funcionou a simulação e demonstrar as conexões de cada sensor ao ESP32:

![image](https://github.com/user-attachments/assets/6dd69b53-680b-40d9-94e6-ad7ee1007077)

Assim, os dados exibidos no monitor serial no canto inferior esquerdo da figura são copiados para um outro arquivo para serem transformados manualmente em um csv.
Importante frisar que essa transformação não pode ser automatizada devido a limitações dentro da plataformna do Wokwi, que por ser um ambiente de simulação, não permite salvar esses dados em arquivos.

Para mais detalhes, voê pode acessar o projeto diretamente da plataforma da wokwi através do link abaixo:
- https://wokwi.com/projects/433610122638702593
  
# Análise Exploratória de Dados Simulados de Sensores Industriais

Contexto Geral
Este projeto tem como objetivo demonstrar a capacidade analítica do grupo frente a dados obtidos por sensores em um ambiente industrial simulado. Apesar dos dados utilizados serem totalmente simulados e com baixa ou nenhuma correlação realista, a estrutura do código busca refletir um cenário prático de monitoramento e análise de sensores como temperatura, umidade e vibração.

Premissas e Limitações
Logo no início do notebook, é feita uma importante ressalva:

"Devido à aleatoriedade dos dados gerados, não é possível tirar qualquer conclusão significativa dos gráficos, pois todos tendem a se manter neutros, o que na prática não aconteceria."

Ou seja, embora os dados representem medições sensoriais típicas de ambientes industriais, sua natureza randômica impede que se tirem inferências reais. Ainda assim, o foco está em demonstrar a capacidade de aplicar ferramentas analíticas sobre esse tipo de dado.

Etapas da Análise
1. Importação e Visualização Inicial dos Dados
Os pacotes pandas, matplotlib.pyplot, seaborn são importados para lidar com análise de dados e visualizações. Em seguida, o arquivo dados_sensores.csv é carregado em um DataFrame, com colunas como:

Timestamp (tempo em segundos)

Temperatura(°C)

Umidade(%)

Vibracao(Hz)

2. Gráfico de Linha - Temperatura ao Longo do Tempo
O primeiro gráfico mostra a evolução temporal da temperatura do equipamento.

O que se esperaria com dados reais: um aumento gradual da temperatura conforme o equipamento opera.

O que é observado: variações caóticas e inconclusivas, típicas de dados aleatórios.

Objetivo: ilustrar como seria monitorado o comportamento térmico real com visualizações temporais.

![Screenshot 2025-06-13 002013](https://github.com/user-attachments/assets/cec2a364-72d6-4526-b041-0a8342cd7dde)

3. Gráfico de Dispersão - Vibração x Tempo
Aqui se busca entender como a vibração evolui ao longo do tempo.

Hipótese prática: a vibração tenderia a aumentar com o tempo, possivelmente acompanhando o aumento de temperatura ou desgaste mecânico.

Resultado com dados simulados: distribuição de pontos aleatória, sem tendência clara.

![Screenshot 2025-06-13 002019](https://github.com/user-attachments/assets/af806141-0512-4667-b8c6-f84031550852)

4. Gráfico de Dispersão - Vibração x Temperatura
Este gráfico visa identificar se há uma correlação entre o aquecimento do sistema e sua vibração.

Esperado na prática: um padrão onde maior temperatura implica em mais vibração, devido à dilatação de componentes e atrito.

Com dados simulados: não há acúmulo progressivo ou relação visível — os dados são dispersos e não estruturados.

![Screenshot 2025-06-13 002033](https://github.com/user-attachments/assets/6369dc9f-31e6-4e01-94ac-b89d3dc6dfbc)

5. Boxplot - Temperatura, Umidade e Vibração
Visualização importante para avaliar distribuições, medianas e outliers de cada sensor.

Importância prática: identificar leituras fora do normal pode indicar falhas iminentes em um sistema real.

Neste caso: as variações são limitadas e os outliers pouco expressivos, devido à uniformidade dos dados simulados.

![Screenshot 2025-06-13 002731](https://github.com/user-attachments/assets/1e2fc8eb-4a79-454c-a23a-a4da0e1cba72)

6. Regressão Linear - Temperatura x Umidade e Temperatura x Vibração
Dois gráficos com regplot foram criados para avaliar possíveis correlações lineares:

Temperatura x Umidade: tendência levemente negativa, mas estatisticamente irrelevante.

Temperatura x Vibração: novamente, nenhuma correlação significativa.

Nota crítica: com dados reais, esperaria-se uma correlação positiva entre temperatura e vibração, ou até mesmo um comportamento de umidade relacionado à eficiência térmica do ambiente.

![Screenshot 2025-06-13 002100](https://github.com/user-attachments/assets/4c746880-a6f5-4403-9f4b-1c4a6a163b18)

![Screenshot 2025-06-13 002656](https://github.com/user-attachments/assets/0f589027-69a3-4ecf-909a-2c6f19f7af8c)

## 👨‍🎓 Divisão de responsabilidades:
- Desenvolvimento do algoritmo de análise gráfica: <a href="https://www.linkedin.com/company/inova-fusca">Jonathan Willian Luft </a> e <a href="https://www.linkedin.com/company/inova-fusca">Fatima Candal</a>
- Testes de Sensores: <a href="https://www.linkedin.com/company/inova-fusca">Gabriel Viel </a>, <a href="https://www.linkedin.com/company/inova-fusca"> Matheus Alboredo Soares</a>,  e <a href="https://www.linkedin.com/company/inova-fusca">Guilherme  Campos Hermanowski </a>


## 🔧 Análise e Construção de Modelos
# Análise dos Modelos de Machine Learning
## Sistema de Monitoramento Industrial

------------*ANALISE DE MODELOS ML*----------------------------------

A matriz mostra as correlações entre as variáveis dos sensores:


<img width="709" height="611" alt="Matriz_Correlacao" src="https://github.com/user-attachments/assets/6ff539ef-9041-4edc-ba3e-e23e93f1078d" />


    • Temperatura e Corrente Elétrica: 0.81 (correlação forte)
        Indica que equipamentos com maior consumo elétrico tendem a aquecer mais
    
    • Temperatura e Vibração: 0.78 (correlação forte)
        Sugere que o aquecimento causa dilatação e desalinhamentos mecânicos
    
    • Pressão e Corrente: 0.52 (correlação moderada)
        Em bombas e compressores, maior pressão demanda mais energia
    
    • Umidade apresenta correlações baixas com outras variáveis
        Comportamento mais independente, influenciado por fatores ambientais



### 2. Diferenças por Classe (Normal vs Falha)


<img width="790" height="490" alt="Media_classe" src="https://github.com/user-attachments/assets/743fb59c-52dd-4bd4-a5eb-624094702920" />


O gráfico demonstra separação clara entre condições normais e de falha:

    Temperatura:
        • Normal: ~62°C
        • Falha: ~86°C (aumento de 38%)
    
    Vibração:
        • Normal: ~5 mm/s
        • Falha: ~11 mm/s (aumento de 120%)
    
    Umidade:
        • Normal: ~44%
        • Falha: ~52% (aumento de 18%)

Estas diferenças significativas facilitam a classificação automática pelos algoritmos.

### 3. Padrões Temporais por Hora

<img width="989" height="490" alt="Media_hora" src="https://github.com/user-attachments/assets/6c0ee28b-aa83-4387-9f7e-c2b80c82c193" />


O gráfico temporal revela:

    • Temperatura: Relativamente estável ao longo do dia (60-65°C)
    • Umidade: Variações moderadas entre turnos (40-48%)
    • Vibração: Comportamento consistente (~5 mm/s)

A estabilidade temporal indica que os padrões de falha dependem mais das condições operacionais do que de ciclos diários.

### 4. Dispersão Temperatura x Vibração

<img width="690" height="490" alt="Temperatura_x_Vibracao" src="https://github.com/user-attachments/assets/fe589d11-b625-401f-81b9-4c76a9ebe4a9" />


O scatter plot confirma duas populações distintas:

    Região Normal (amarelo):
        • Temperatura: 25-75°C
        • Vibração: 2-6 mm/s
        • Distribuição concentrada
    
    Região de Falha (azul):
        • Temperatura: 75-110°C
        • Vibração: 6-20 mm/s
        • Maior dispersão, indicando diferentes tipos de falha

A separação visual clara entre as classes valida a qualidade dos dados para treinamento.

### 5. Performance dos Modelos de Machine Learning

<img width="989" height="590" alt="Comparacao_Acuracia_modelos" src="https://github.com/user-attachments/assets/2d4e64b6-632e-41ac-8d07-4567075117aa" />


Todos os algoritmos apresentaram performance elevada:

    Regressão Logística: 95.7%
        • Modelo linear simples e interpretável
        • Eficiente computacionalmente
        • Adequado quando as relações são aproximadamente lineares
    
    SVM (Support Vector Machine): 95.6%
        • Robusto para datasets pequenos/médios
        • Funciona bem com fronteiras não-lineares
        • Menos sensível a outliers
    
    Random Forest: 95.3%
        • Ensemble de árvores de decisão
        • Reduz overfitting através de bootstrap
        • Fornece importância das features
    
    KNN (K-Nearest Neighbors): 94.9%
        • Algoritmo baseado em similaridade
        • Não assume distribuição específica dos dados
        • Sensível à escala das features

### Análise Crítica da Performance

A alta acurácia em todos os modelos (94.9% - 95.7%) indica:

    Pontos Positivos:
        • Dados bem estruturados com correlações claras
        • Separação efetiva entre classes normal/falha
        • Features relevantes para predição
    
    Pontos de Atenção:
        • Diferença mínima entre modelos pode indicar overfitting
        • Necessário validar com dados de produção
        • Avaliar outras métricas além da acurácia (precision, recall, F1-score)

### Recomendações

    Para Produção:
        • Iniciar com Regressão Logística pela simplicidade e interpretabilidade
        • Implementar monitoramento contínuo da performance
        • Coletar feedback dos operadores para validação
    
    Para Melhoria:
        • Incluir dados de mais máquinas para generalização
        • Testar com janelas temporais diferentes (1h, 4h, 8h)
        • Considerar features derivadas (médias móveis, tendências)

### Conclusão

O sistema demonstra capacidade técnica sólida para predição de falhas. A consistência entre diferentes algoritmos valida a qualidade do modelo de dados implementado. O próximo passo é a validação em ambiente de produção com métricas operacionais reais.

## A documentação referente as entidades e seus relacionamentos esta junto ao repositório, por ser muito extença optamos por não escreve-la no readme (documentacao_entidades)
