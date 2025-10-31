# Projeto Banco de Dados — Sistema de E-commerce  

## Descrição  
Este projeto foi desenvolvido com o objetivo de modelar e implementar um banco de dados relacional para um **sistema de e-commerce**, permitindo o cadastro de clientes, produtos, pedidos, entregas e pagamentos.  

Durante o desenvolvimento, o modelo inicial foi **refinado e aprimorado** com novas funcionalidades e normalizações, mantendo a integridade dos dados e a escalabilidade do sistema.  

---

## Melhorias Implementadas  

### 1. Adição da Tabela de Endereços  
Inicialmente, o campo de endereço estava diretamente dentro da tabela `clients`, o que limitava o cadastro de múltiplos endereços por cliente.  
Para corrigir isso, foi criada uma nova tabela chamada `address`, por meio de **chave estrangeira (foreign key)**, permitindo que **um cliente possua vários endereços** (relação 1:N).

Dessa forma, foi possível permitir que um mesmo cliente tenha **um ou mais endereços**.

```sql
-- Nova tabela de endereços
create table adress (	
    idAddress int auto_increment primary key,
    idClient INT,
    adress VARCHAR(30),
    foreign key (idClient) references clients(idClient)
);

-- Migração dos endereços existentes da tabela antiga
insert into adress(idClient, adress)
select idClient, Adress
from clients;
```
Essa modificação trouxe melhor normalização dos dados e maior flexibilidade para futuras operações relacionadas a endereços.



### 2. Adição de Cliente PF e PJ 
Foi implementado o controle de tipo de `cliente`, diferenciando Pessoa Física (PF) e Pessoa Jurídica (PJ).
Cada conta pode ser **apenas de um tipo**, nunca ambos.

```sql
ALTER TABLE clients ADD COLUMN type ENUM('PF', 'PJ') NOT NULL;
ALTER TABLE clients ADD COLUMN CNPJ CHAR(14);
```

### 3. Adição da Tabela de Pagamento

Foi criada uma tabela `payments` para permitir o cadastro de múltiplas formas de pagamento por cliente, atendendo ao requisito de **flexibilidade** no checkout.

```sql
create table payments(
idClient int, 
id_payment int, 
typePayment enum('Dinheiro', 'Boleto', 'Cartão', 'Dois Cartões'),
limitAvailable float,
primary key (idClient, id_payment)
);

-- Tabela Pagamento pode ter cadastrado mais de uma forma de pagamento;
alter table payments
add column payment_status enum('Ativo', 'Inativo') default 'Ativo';
```

### 4. Adição da Tabela de Entrega

Para controlar o fluxo de envio de pedidos, foi criada a tabela deliveries, com status e código de rastreio.

```sql
create table delivery (
    idDelivery int auto_increment primary key,
    idOrder int,
    trackingCode varchar(50),
    deliveryStatus enum('Em transporte', 'Entregue', 'Cancelada') default 'Em transporte',
    deliveryDate date,
    constraint fk_delivery_order foreign key (idOrder) references orders(idOrder)
);

insert into delivery (idOrder, trackingCode, deliveryStatus, deliveryDate)
values
(1, 'BR123456789', 'Entregue', '2024-10-20'),
(2, 'BR987654321', 'Em transporte', null),
(4, 'BR555444333', 'Cancelada', null);
```

## Consultas Realizadas

### Recuperações simples com SELECT Statement

```sql
select * from product;
select Fname as Produto, category as Categoria from product;
```

### Filtros com WHERE

```sql
select Fname, category, avaliação from product where category = 'Eletrônico';
select Fname, Lname, CPF from clients where CPF like '1%';
```

### Expressões para gerar atributos derivados
Criando um campo com valor total do pedido (frete + R$ 20 como exemplo):

```sql
select 
    idOrder,
    orderDescription as Descrição,
    sendValue as Valor_Envio,
    sendValue + 20 AS Total
from orders;
```

Mostrando se o cliente paga com dinheiro (sim/não):

```sql
select 
    idOrder,
    orderDescription as Descrição_do_Produto,
    case 
        when paymentCash = true then 'Sim'
        else 'Não'
    end as Pagamento_em_dinheiro
from orders;
```

### Ordenações com ORDER BY
Ordenando produtos da maior para a menor avaliação:

```sql
select Fname, avaliação
from product
order by avaliação desc;
```

Ordenando clientes pelo sobrenome:
```sql
select Fname, Lname
from clients
order by Lname asc;
```

### Agrupamentos e filtros de grupo (GROUP BY + HAVING)
Contando quantos produtos há por categoria:

```sql
select category, COUNT(*) as TotalProdutos
from product
group by category;
```
Mostrando apenas as categorias com mais de 1 produto:

```sql
select category, COUNT(*) as TotalProdutos
from product
group by category
having COUNT(*) > 0;
```

### Junções entre tabelas (INNER JOIN)
Mostrando os pedidos com o nome do cliente

```sql
select 
    o.idOrder,
    c.Fname as NomeCliente,
    o.orderDescription,
    o.orderStatus
from orders o
inner join clients c 
    on o.idOrderClient = c.idClient;
```

Mostrando os produtos e seus respectivos fornecedores

```sql
select 
    p.Fname as Produto,
    s.socialName as Fornecedor,
    ps.quantity as QuantidadeFornecida
from productSupplier ps
inner join product p on ps.idPsProduct = p.idProduct
inner join supplier s on ps.idPsSupplier = s.idSupplier;
```

# RESPONDENDO PERGUNTAS DE NEGÓCIOS

## Quais são os nomes e CPFs de todos os clientes cadastrados?

```sql
select concat(Fname, ' ', Lname ) as Cliente, CPF from clients;
```

## Quais produtos são da categoria "Brinquedos"?

```sql
select Fname, category from product
where category = 'Brinquedos';
```

## Quais produtos têm avaliação maior que 4.5, em ordem decrescente?

```sql
select Fname, category from product
where category = 'Brinquedos';select Fname, avaliação from product
where avaliação > 4.5
order by avaliação desc;
```

## Quais clientes moram na “Rua das Flores”?

```sql
select Fname, Lname, Adress from clients
where Adress like '%Rua das Flores%';
```

## Qual é a média de avaliação dos produtos por categoria?

```sql
select category, avg(avaliação) as media_avaliacao
from product
group by category;
```

## Quantos produtos estão cadastrados em cada categoria?

```sql
select category, count(*) as total_produtos
from product
group by category;
```

## Qual categoria tem mais produtos cadastrados (usando HAVING)?

```sql
select category, count(*) as total_produtos
from product
group by category
having total_produtos = (
    select max(contagem) 
    from (select count(*) as contagem from product group by category) as temp
);
```

##  Qual o valor total de frete (sendValue) de todos os pedidos confirmados?

```sql
select sum(sendValue) as total_frete
from orders
where orderStatus = 'Confirmado';
```

##  Quais clientes fizeram pedidos e quais produtos estavam nesses pedidos?

```sql
select c.Fname, c.Lname, p.Fname as Produto, o.orderStatus
from clients c
inner join orders o on c.idClient = o.idOrderClient
inner join productOrder po on o.idOrder = po.idPOorder
inner join product p on po.idPOproduct = p.idProduct;
```

##  Quais produtos estão sem estoque?

```sql
select p.Fname, po.poStatus
from product p
inner join productOrder po on p.idProduct = po.idPOproduct
where po.poStatus = 'Sem estoque';
```

##  Quais fornecedores fornecem cada produto e em que quantidade?

```sql
select s.socialName as Fornecedor, p.Fname as Produto, ps.quantity
from supplier s
inner join productSupplier ps on s.idSupplier = ps.idPsSupplier
inner join product p on ps.idPsProduct = p.idProduct;
```

##  Qual galpão armazena mais produtos (usando GROUP BY e ORDER BY)?

```sql
select ps.storageLocation, sum(ps.quantity) as total
from productStorage ps
group by ps.storageLocation
order by total desc;
```


## Conclusão

Durante o desenvolvimento deste projeto, foi possível:

 - Melhorar a normalização do banco de dados, separando endereços em uma tabela específica.

 - Garantir a integridade referencial entre tabelas por meio de chaves estrangeiras.

 - Criar consultas SQL de diferentes níveis, utilizando:

`SELECT`, `WHERE`, `ORDER BY`

 - Funções de agregação (AVG, COUNT, SUM)

 - GROUP BY e HAVING

 - INNER JOIN para combinar informações de múltiplas tabelas

 - Responder perguntas de negócio reais, mostrando a utilidade prática do banco.


## Autora

Lais Lopes Silva - Estudante de Análise e Desenvolvimento de Sistemas

📚 Projeto acadêmico desenvolvido como parte de estudos sobre bancos de dados relacionais e SQL.

### Tecnologias utilizadas: 

MySQL — Modelagem e implementação das tabelas

Workbench / DBeaver — Ferramenta de visualização e testes

SQL (Structured Query Language) — Linguagem principal para consultas e manipulação de dados

