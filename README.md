
# 🚀 TechCare Support - Salesforce Project

## 🎯 Objetivo

Sistema de **gestão de requisições de suporte** com diferenciação entre clientes **Standard** e **Premium** e  
- Cálculo automático de **SLA**.  
- Fluxos de atribuição e validação.  
- Visualização e interação via **LWC**.  
- Notificações automáticas para o time de suporte.  
- Relatórios e Dashboards para acompanhamento.

## ⚙️ Funcionalidades

### ✅ Campos e Objetos
- **Case_Request__c**: objeto principal.
- **Case_History__c**: histórico de fechamento e validação de SLA.

**Campos principais:**
- `Priority__c` → Low, Medium, High.
- `Status__c` → New, In Progress, Escalated, Closed.
- `SLA_Deadline__c` → calculado automaticamente.
- `Product_Serial_Number__c` → obrigatório para **Standard**.
- `Business_Function_Affected__c` → obrigatório para **Premium**.
- `Resolution_Notes__c` → exibido após `Status = Closed`.
- `Customer_Satisfaction_Score__c` → exibido após `Status = Closed`.

---

### ✅ Record Types
- **Standard** → processo básico, requer número de série.
- **Premium** → fluxo premium, com função de negócio impactada, possibilidade de mudar o status e botão para contatar diretamente a equipe de suporte.

---

### ✅ Flows
- **Record-Triggered Flow** →  
  - Ao criar:  
    - Se `RecordType = Premium` → `SLA = NOW() + 8h`.  
    - Se `Standard` → `SLA = NOW() + 24h`.  
  - Se `Status` está vazio → atribui `Status = New`.  
  - Se `Priority = High` e `RecordType = Premium` → notifica Owner e atribui ao usuário específico.  

- **Email Notification Flow** →  
  - Quando `Priority = High` e `RecordType = Premium` → envia **email** para o `Owner`.

---

### ✅ Validation Rules
- **Obrigatório preencher `Resolution_Notes__c`** ao fechar o caso.  
- `Product_Serial_Number__c` → obrigatório apenas para `Standard`.  
- `Business_Function_Affected__c` → obrigatório apenas para `Premium`.  

---

### ✅ Apex Classes

**CaseRequestController**  
- `getCaseDetails(caseId)` → detalhes para o LWC.  
- `reopenCase(caseId)` → reabre caso e recalcula `SLA`.  
- `contactSupport(caseId)` → envia email para o suporte.

**CaseInfoResource**  
- REST Resource: `/services/apexrest/caseinfo/{caseId}`  
- Retorna JSON com:  
  - `caseId`  
  - `status`  
  - `slaMet` → boolean se SLA foi cumprido.

**CaseHistoryController**  
- `getHistory(caseId)` → lista de históricos.

---

### ✅ Apex Trigger

**CaseRequestTrigger**  
- Ao atualizar para `Closed`:  
  - Cria `Case_History__c`.  
  - Define `SLA_Met__c`.  

---

## 💻 LWC Components

**CaseStatusComponent**  
- Exibe **SLA Countdown** com animações e cores:  
- Normal, Warning, Urgent, Expired.  
- Botão "Reopen Case" → para reabrir o chamado.  
- Exibe `Status` como **badge**.
- Exibe button apenas para `Premium` para contatar rapidamente a equipe de suporte.


**CaseTimeline**  
- Exibe timeline com histórico de `Case_History__c`.  

---

## 📝 Dynamic Forms  
- `Customer_Satisfaction_Score__c` → visível só após `Status = Closed`.  
- `Product_Serial_Number__c` → obrigatório apenas em `Standard`.  
- `Status__c` → visível, mas **não editável** para usuários Standard.  

---

## 📨 Emails Automáticos
- Envio de email ao **Owner** → quando `Priority = High` e `RecordType = Premium`.  
- Botão “Contact Support” → envia email diretamente ao suporte.

---

## 📊 Relatórios e Dashboards

**Relatórios:**
- Casos abertos por **Prioridade** e **Status**.  
- Casos fechados últimos 7 dias.

**Dashboard:**
- Gráfico: **Abertos x Fechados** últimos 7 dias.  
- **Tempo médio de resolução** → Premium x Standard.  

---

## ✅ Test Coverage

# código com comentários explicando o que cada um faz

- Classes de Teste:  
  - `CaseRequestControllerTest`  
  - `CaseInfoResourceTest`  
  - `CaseHistoryControllerTest`  
  - `TriggerHandlerTest`  

Incluindo testes de:  
- Reabertura de caso.  
- GET na API REST.  
- Contato com suporte.  

---

## 🚀 Como Instalar

1. Clone o repositório:  
```bash
git clone https://github.com/juliapinheiro42/techcare-support.git
cd techcare-support
```

2. Deploy:  
```bash
sfdx force:source:deploy -p force-app
```

3. Execute os testes:  
```bash
sfdx force:apex:test:run --resultformat human
```

4. Atribua **Permission Sets**:  
```bash
sfdx force:user:permset:assign -n Support_Standard
sfdx force:user:permset:assign -n Support_Premium
```

---

## ✅ Como Testar

### ✅ Criar um Case  
- Como Standard → requer `Product_Serial_Number__c`.  
- Como Premium → requer `Business_Function_Affected__c`.  

### ✅ Validar  
- Não permite fechar sem `Resolution_Notes__c`.  
- SLA calculado automaticamente.

### ✅ Flows  
- Reabre → reseta SLA.  
- Caso Premium e Priority High → envia email ao Owner.  

### ✅ LWC  
- SLA countdown → animado.  
- Botão “Reopen” → só se `Status = Closed`.

### ✅ API  
- Chamada REST:  
```bash
GET /services/apexrest/caseinfo/{caseId}
```

---

## ✅ Melhorias que pensei para o futuro

- Automatizar envio de **agradecimento** após `Customer_Satisfaction_Score__c`.  
- Relatório de **média de satisfação** por agente.  
- Expor mais endpoints REST para integração.  
- Criar possibilidade de contatar equipe de support se status is not closed e SLA_Met is false
---

## ✨ Autor

**Julia Farias**  
[LinkedIn](https://linkedin.com/in/juliapinheirodefarias) | [GitHub](https://github.com/juliapinheiro42)

---

## 🚀 Powered by Salesforce Platform & Lightning Web Components
