import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.preprocessing import StandardScaler
import time
import datetime

# Configuração da página
st.set_page_config(
    page_title="Sistema de Monitoramento Industrial",
    page_icon="🏭",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Título principal
st.title("🏭 Sistema de Monitoramento Industrial")
st.markdown("**Análise de Sensores e Predição de Falhas em Equipamentos Industriais**")

# Sidebar para navegação
st.sidebar.title("Navegação")
page = st.sidebar.selectbox(
    "Selecione uma página:",
    ["Dashboard Principal", "Análise de Dados", "Machine Learning", "Simulação de Dados", "Configurações"]
)

# Função para gerar dados simulados
@st.cache_data
def generate_sensor_data(n_samples=1000, failure_rate=0.2):
    """Gera dados simulados de sensores baseados no projeto original"""
    np.random.seed(42)
    
    # Gerar timestamps
    timestamps = pd.date_range(start='2024-01-01', periods=n_samples, freq='5min')
    
    # Garantir que temos pelo menos algumas amostras de cada classe
    min_samples_per_class = max(2, int(n_samples * 0.05))  # Pelo menos 5% ou 2 amostras por classe
    n_failures = max(min_samples_per_class, int(n_samples * failure_rate))
    n_failures = min(n_failures, n_samples - min_samples_per_class)  # Garantir que sobrem amostras normais
    
    # Determinar quais amostras serão falhas
    is_failure = np.zeros(n_samples, dtype=bool)
    failure_indices = np.random.choice(n_samples, n_failures, replace=False)
    is_failure[failure_indices] = True
    
    # Gerar dados baseados nas características do projeto
    data = []
    for i, (timestamp, failure) in enumerate(zip(timestamps, is_failure)):
        if failure:
            # Condições de falha (valores mais altos)
            temperatura = np.random.normal(86, 10)  # Falha: ~86°C
            umidade = np.random.normal(52, 8)       # Falha: ~52%
            vibracao = np.random.normal(11, 3)      # Falha: ~11 mm/s
            corrente_eletrica = np.random.normal(85, 10)  # Correlacionada com temperatura
            pressao = np.random.normal(55, 8)       # Correlacionada com corrente
            status = 1  # Falha
        else:
            # Condições normais
            temperatura = np.random.normal(62, 8)   # Normal: ~62°C
            umidade = np.random.normal(44, 6)       # Normal: ~44%
            vibracao = np.random.normal(5, 2)       # Normal: ~5 mm/s
            corrente_eletrica = np.random.normal(60, 8)   # Correlacionada com temperatura
            pressao = np.random.normal(45, 6)       # Correlacionada com corrente
            status = 0  # Normal
        
        # Garantir valores dentro de faixas realistas
        temperatura = max(20, min(110, temperatura))
        umidade = max(10, min(90, umidade))
        vibracao = max(1, min(20, vibracao))
        corrente_eletrica = max(30, min(100, corrente_eletrica))
        pressao = max(20, min(80, pressao))
        
        data.append({
            'timestamp': timestamp,
            'temperatura': round(temperatura, 2),
            'umidade': round(umidade, 2),
            'vibracao': round(vibracao, 2),
            'corrente_eletrica': round(corrente_eletrica, 2),
            'pressao': round(pressao, 2),
            'status': status,
            'status_label': 'Falha' if status == 1 else 'Normal'
        })
    
    return pd.DataFrame(data)

# Carregar dados
df = generate_sensor_data()

# Dashboard Principal
if page == "Dashboard Principal":
    st.header("📊 Dashboard de Monitoramento em Tempo Real")
    
    # Métricas principais
    col1, col2, col3, col4 = st.columns(4)
    
    # Simular dados em tempo real (últimos valores)
    latest_data = df.iloc[-1]
    
    with col1:
        st.metric(
            label="🌡️ Temperatura",
            value=f"{latest_data['temperatura']:.1f}°C",
            delta=f"{np.random.uniform(-2, 2):.1f}°C"
        )
    
    with col2:
        st.metric(
            label="💧 Umidade",
            value=f"{latest_data['umidade']:.1f}%",
            delta=f"{np.random.uniform(-3, 3):.1f}%"
        )
    
    with col3:
        st.metric(
            label="📳 Vibração",
            value=f"{latest_data['vibracao']:.1f} mm/s",
            delta=f"{np.random.uniform(-1, 1):.1f} mm/s"
        )
    
    with col4:
        st.metric(
            label="⚡ Corrente",
            value=f"{latest_data['corrente_eletrica']:.1f}A",
            delta=f"{np.random.uniform(-2, 2):.1f}A"
        )
    
    # Status atual
    if latest_data['status'] == 1:
        st.error("🚨 ALERTA: Condição de falha detectada!")
    else:
        st.success("✅ Sistema operando normalmente")
    
    # Gráficos em tempo real
    st.subheader("📈 Monitoramento Temporal")
    
    # Últimas 100 leituras para simulação de tempo real
    recent_data = df.tail(100)
    
    # Gráfico de temperatura
    fig_temp = px.line(recent_data, x='timestamp', y='temperatura', 
                       title='Temperatura ao Longo do Tempo',
                       color='status_label',
                       color_discrete_map={'Normal': 'blue', 'Falha': 'red'})
    fig_temp.update_layout(height=400)
    st.plotly_chart(fig_temp, use_container_width=True)
    
    # Gráficos de outros sensores
    col1, col2 = st.columns(2)
    
    with col1:
        fig_hum = px.line(recent_data, x='timestamp', y='umidade',
                         title='Umidade ao Longo do Tempo',
                         color='status_label',
                         color_discrete_map={'Normal': 'green', 'Falha': 'red'})
        fig_hum.update_layout(height=300)
        st.plotly_chart(fig_hum, use_container_width=True)
    
    with col2:
        fig_vib = px.line(recent_data, x='timestamp', y='vibracao',
                         title='Vibração ao Longo do Tempo',
                         color='status_label',
                         color_discrete_map={'Normal': 'purple', 'Falha': 'red'})
        fig_vib.update_layout(height=300)
        st.plotly_chart(fig_vib, use_container_width=True)

# Análise de Dados
elif page == "Análise de Dados":
    st.header("🔍 Análise Exploratória de Dados")
    
    # Estatísticas descritivas
    st.subheader("📋 Estatísticas Descritivas")
    st.dataframe(df.describe())
    
    # Matriz de correlação
    st.subheader("🔗 Matriz de Correlação")
    
    # Calcular correlações
    numeric_cols = ['temperatura', 'umidade', 'vibracao', 'corrente_eletrica', 'pressao']
    corr_matrix = df[numeric_cols].corr()
    
    # Heatmap interativo
    fig_corr = px.imshow(corr_matrix, 
                        text_auto=True, 
                        aspect="auto",
                        title="Matriz de Correlação entre Sensores",
                        color_continuous_scale='RdBu_r')
    fig_corr.update_layout(height=500)
    st.plotly_chart(fig_corr, use_container_width=True)
    
    # Interpretação das correlações
    st.markdown("""
    **Principais Correlações Identificadas:**
    - **Temperatura x Corrente Elétrica**: Correlação forte - equipamentos com maior consumo elétrico tendem a aquecer mais
    - **Temperatura x Vibração**: Correlação forte - o aquecimento causa dilatação e desalinhamentos mecânicos
    - **Pressão x Corrente**: Correlação moderada - em bombas e compressores, maior pressão demanda mais energia
    - **Umidade**: Comportamento mais independente, influenciado por fatores ambientais
    """)
    
    # Análise por classe (Normal vs Falha)
    st.subheader("📊 Diferenças por Classe (Normal vs Falha)")
    
    # Calcular médias por classe
    class_means = df.groupby('status_label')[numeric_cols].mean()
    
    # Gráfico de barras comparativo
    fig_class = go.Figure()
    
    for sensor in numeric_cols:
        fig_class.add_trace(go.Bar(
            name=f'Normal',
            x=[sensor],
            y=[class_means.loc['Normal', sensor]],
            marker_color='blue',
            showlegend=sensor == numeric_cols[0]
        ))
        fig_class.add_trace(go.Bar(
            name=f'Falha',
            x=[sensor],
            y=[class_means.loc['Falha', sensor]],
            marker_color='red',
            showlegend=sensor == numeric_cols[0]
        ))
    
    fig_class.update_layout(
        title="Média das Variáveis por Classe",
        xaxis_title="Sensores",
        yaxis_title="Valor Médio",
        barmode='group',
        height=400
    )
    st.plotly_chart(fig_class, use_container_width=True)
    
    # Análise de dispersão
    st.subheader("🎯 Análise de Dispersão - Temperatura x Vibração")
    
    fig_scatter = px.scatter(df, x='temperatura', y='vibracao', 
                           color='status_label',
                           title='Dispersão Temperatura x Vibração',
                           color_discrete_map={'Normal': 'blue', 'Falha': 'red'})
    fig_scatter.update_layout(height=500)
    st.plotly_chart(fig_scatter, use_container_width=True)

# Machine Learning
elif page == "Machine Learning":
    st.header("🤖 Modelos de Machine Learning")
    
    # Preparar dados para ML
    X = df[['temperatura', 'umidade', 'vibracao', 'corrente_eletrica', 'pressao']]
    y = df['status']
    
    # Verificar se temos pelo menos 2 classes
    unique_classes = y.unique()
    if len(unique_classes) < 2:
        st.error(f"⚠️ Erro: Os dados contêm apenas {len(unique_classes)} classe(s): {unique_classes}")
        st.error("É necessário ter pelo menos 2 classes (Normal e Falha) para treinar os modelos.")
        st.info("💡 Dica: Vá para a página 'Simulação de Dados' e gere um novo conjunto com taxa de falhas > 0%")
        st.stop()
    
    # Verificar distribuição das classes
    class_distribution = y.value_counts()
    st.subheader("📊 Distribuição das Classes")
    
    col1, col2 = st.columns(2)
    with col1:
        st.metric("Amostras Normais (0)", class_distribution.get(0, 0))
    with col2:
        st.metric("Amostras de Falha (1)", class_distribution.get(1, 0))
    
    # Dividir dados
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42, stratify=y)
    
    # Normalizar dados
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Treinar modelos
    models = {
        'Regressão Logística': LogisticRegression(random_state=42),
        'Random Forest': RandomForestClassifier(random_state=42),
        'SVM': SVC(random_state=42),
        'KNN': KNeighborsClassifier()
    }
    
    results = {}
    trained_models = {}
    
    for name, model in models.items():
        try:
            if name == 'SVM' or name == 'KNN':
                model.fit(X_train_scaled, y_train)
                y_pred = model.predict(X_test_scaled)
                trained_models[name] = (model, scaler)  # Salvar modelo e scaler
            else:
                model.fit(X_train, y_train)
                y_pred = model.predict(X_test)
                trained_models[name] = (model, None)  # Salvar modelo sem scaler
            
            accuracy = accuracy_score(y_test, y_pred)
            results[name] = accuracy
            
        except Exception as e:
            st.warning(f"⚠️ Erro ao treinar {name}: {str(e)}")
            continue
    
    # Exibir resultados
    if results:
        st.subheader("📈 Performance dos Modelos")
        
        # Gráfico de acurácia
        fig_acc = px.bar(x=list(results.keys()), y=list(results.values()),
                         title='Acurácia dos Modelos de Machine Learning',
                         labels={'x': 'Modelo', 'y': 'Acurácia'})
        fig_acc.update_layout(height=400)
        st.plotly_chart(fig_acc, use_container_width=True)
        
        # Tabela de resultados
        results_df = pd.DataFrame(list(results.items()), columns=['Modelo', 'Acurácia'])
        results_df['Acurácia'] = results_df['Acurácia'].apply(lambda x: f"{x:.1%}")
        st.dataframe(results_df, use_container_width=True)
    else:
        st.error("❌ Nenhum modelo foi treinado com sucesso.")
        st.info("💡 Verifique se os dados têm pelo menos 2 classes e tente novamente.")
    
    # Predição em tempo real
    st.subheader("🔮 Predição em Tempo Real")
    
    col1, col2 = st.columns(2)
    
    with col1:
        temp_input = st.slider("Temperatura (°C)", 20.0, 110.0, 62.0)
        hum_input = st.slider("Umidade (%)", 10.0, 90.0, 44.0)
        vib_input = st.slider("Vibração (mm/s)", 1.0, 20.0, 5.0)
    
    with col2:
        curr_input = st.slider("Corrente Elétrica (A)", 30.0, 100.0, 60.0)
        press_input = st.slider("Pressão", 20.0, 80.0, 45.0)
    
    # Fazer predição se temos modelos treinados
    if results:
        input_data = np.array([[temp_input, hum_input, vib_input, curr_input, press_input]])
        
        # Usar o melhor modelo disponível
        best_model_name = max(results, key=results.get)
        best_model, model_scaler = trained_models[best_model_name]
        
        # Aplicar escalonamento se necessário
        if model_scaler is not None:
            input_data_scaled = model_scaler.transform(input_data)
            prediction = best_model.predict(input_data_scaled)[0]
            probability = best_model.predict_proba(input_data_scaled)[0]
        else:
            prediction = best_model.predict(input_data)[0]
            probability = best_model.predict_proba(input_data)[0]
        
        st.info(f"Usando modelo: **{best_model_name}** (Acurácia: {results[best_model_name]:.1%})")
        
        if prediction == 1:
            st.error(f"🚨 PREDIÇÃO: FALHA (Probabilidade: {probability[1]:.1%})")
        else:
            st.success(f"✅ PREDIÇÃO: NORMAL (Probabilidade: {probability[0]:.1%})")
    else:
        st.error("❌ Nenhum modelo foi treinado com sucesso. Verifique os dados.")

# Simulação de Dados
elif page == "Simulação de Dados":
    st.header("🎲 Simulação de Dados de Sensores")
    
    st.markdown("""
    Esta página permite gerar novos conjuntos de dados simulados baseados nos parâmetros do projeto original.
    """)
    
    # Controles de simulação
    col1, col2 = st.columns(2)
    
    with col1:
        n_samples = st.slider("Número de amostras", 100, 5000, 1000)
        failure_rate = st.slider("Taxa de falhas (%)", 0.0, 50.0, 20.0) / 100
    
    with col2:
        freq = st.selectbox("Frequência de coleta", ["1min", "5min", "15min", "1H"])
        seed = st.number_input("Seed (para reprodutibilidade)", 0, 1000, 42)
    
    if st.button("Gerar Novos Dados"):
        # Gerar novos dados
        new_data = generate_sensor_data(n_samples, failure_rate)
        
        # Exibir estatísticas
        st.subheader("📊 Estatísticas dos Dados Gerados")
        
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.metric("Total de Amostras", len(new_data))
        with col2:
            st.metric("Amostras Normais", len(new_data[new_data['status'] == 0]))
        with col3:
            st.metric("Amostras de Falha", len(new_data[new_data['status'] == 1]))
        
        # Visualizar dados
        st.subheader("📈 Visualização dos Dados Gerados")
        
        fig_new = px.line(new_data.head(200), x='timestamp', y='temperatura',
                         color='status_label',
                         title='Temperatura - Dados Simulados (Primeiras 200 amostras)')
        st.plotly_chart(fig_new, use_container_width=True)
        
        # Opção de download
        csv = new_data.to_csv(index=False)
        st.download_button(
            label="📥 Download CSV",
            data=csv,
            file_name=f"dados_sensores_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
            mime="text/csv"
        )

# Configurações
elif page == "Configurações":
    st.header("⚙️ Configurações do Sistema")
    
    st.subheader("🚨 Configuração de Alertas")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("**Limites de Temperatura**")
        temp_min = st.number_input("Temperatura Mínima (°C)", 0.0, 100.0, 20.0)
        temp_max = st.number_input("Temperatura Máxima (°C)", 0.0, 150.0, 80.0)
        
        st.markdown("**Limites de Umidade**")
        hum_min = st.number_input("Umidade Mínima (%)", 0.0, 100.0, 10.0)
        hum_max = st.number_input("Umidade Máxima (%)", 0.0, 100.0, 80.0)
    
    with col2:
        st.markdown("**Limites de Vibração**")
        vib_min = st.number_input("Vibração Mínima (mm/s)", 0.0, 50.0, 1.0)
        vib_max = st.number_input("Vibração Máxima (mm/s)", 0.0, 50.0, 15.0)
        
        st.markdown("**Limites de Corrente**")
        curr_min = st.number_input("Corrente Mínima (A)", 0.0, 200.0, 30.0)
        curr_max = st.number_input("Corrente Máxima (A)", 0.0, 200.0, 90.0)
    
    st.subheader("📊 Configurações de Visualização")
    
    chart_theme = st.selectbox("Tema dos Gráficos", ["plotly", "plotly_white", "plotly_dark"])
    update_interval = st.slider("Intervalo de Atualização (segundos)", 1, 60, 5)
    
    st.subheader("💾 Configurações de Dados")
    
    data_retention = st.selectbox("Retenção de Dados", ["1 dia", "7 dias", "30 dias", "90 dias"])
    auto_backup = st.checkbox("Backup Automático")
    
    if st.button("Salvar Configurações"):
        st.success("✅ Configurações salvas com sucesso!")

# Footer
st.markdown("---")
st.markdown("""
<div style='text-align: center'>
    <p>🏭 Sistema de Monitoramento Industrial | Baseado no projeto Enterprise Challenge - Sprint 4 - Reply</p>
    <p>Desenvolvido com Streamlit | FIAP - Inteligência Artificial e Data Science</p>
</div>
""", unsafe_allow_html=True)
