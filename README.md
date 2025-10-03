# Enterprise-Challenge---Sprint-4---Reply

# FIAP - Inteligência artificial e data science

<p align="center">
<a href= "https://www.fiap.com.br/"><img src="assets/logo-fiap.png" alt="FIAP - Faculdade de Informática e Admnistração Paulista" border="0" width=40% height=40%></a>
</p>

## Nome do grupo
25

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
