
create database ecommerce;
use ecommerce; 


-- Criar tabela Cliente
create table clients(

idClient int auto_increment primary key,
Fname varchar(10),
Minit char(3),
Lname varchar(20),
CPF char(11) not null,
Adress varchar(30),
constraint unique_cpf_client unique (CPF)
);

-- REFINAMENTOS --

-- Cliente PJ e PF – Uma conta pode ser PJ ou PF, mas não pode ter as duas informações;
alter table clients add column type enum('PF', 'PJ') not null;
alter table clients add column CNPJ char(14);


-- Criando nova tabela para guardar os endereços separadamente, vinculando cada um ao cliente correspondente. 
-- permitindo que o sistema aceite mais de um endereço por cliente

drop table adress;
create table adress (	
    idAddress int auto_increment primary key,
    idClient INT,
    adress VARCHAR(30),
    foreign key (idClient) references clients(idClient)
);
-- Copiar os dados antigos de endereço para a nova tabela

insert into adress(idClient, adress)
select idClient, Adress
from clients;

-- Visualizando 
select c.Fname, c.Lname, a.adress
from clients c
inner join adress a on c.idClient = a.idClient;


-- Povoando a tabela clients
INSERT INTO clients (Fname, Minit, Lname, CPF, Adress)
VALUES
('Ana', 'M', 'Silva', '12345678901', 'Rua das Flores, 123'),
('Bruno', 'A', 'Souza', '23456789012', 'Av. Central, 456'),
('Carla', 'B', 'Oliveira', '34567890123', 'Rua da Paz, 789'),
('Diego', 'C', 'Pereira', '45678901234', 'Travessa Azul, 321'),
('Elaine', 'D', 'Costa', '56789012345', 'Rua Nova, 654');

alter table clients auto_increment=1;

-- Criar tabela Produto
create table product(
idProduct int auto_increment primary key,
Fname varchar(10) not null,
classification_kids bool default false,
category enum('Eletrônico', 'Vestimenta', 'Brinquedos', 'Alimentos', 'Móveis') not null,
avaliação float default 0,
size varchar(10)
);

INSERT INTO product (Fname, classification_kids, category, avaliação, size)
VALUES
('Notebook', false, 'Eletrônico', 4.8, '15pol'),
('Camiseta', false, 'Vestimenta', 4.5, 'M'),
('Boneca', true, 'Brinquedos', 4.9, null),
('Chocolate', true, 'Alimentos', 4.2, '100g'),
('Sofá', false, 'Móveis', 4.7, '3Lug');


create table payments(
idClient int, -- Completar o restante
id_payment int, 
typePayment enum('Dinheiro', 'Boleto', 'Cartão', 'Dois Cartões'),
limitAvailable float,
primary key (idClient, id_payment)
);

-- Tabela Pagamento pode ter cadastrado mais de uma forma de pagamento;
alter table payments
add column payment_status enum('Ativo', 'Inativo') default 'Ativo';


-- Conectando idClient à tabela clients 
alter table payments 
add constraint fk_payment_client
foreign key (idClient) references clients(idClient)
on update cascade 
on delete cascade;

-- Criar tabela Pedido
create table orders(
idOrder int auto_increment primary key,
idOrderClient int,
orderStatus enum('Cancelado', 'Confirmado', 'Em Processamento') default 'Em processamento',
orderDescription varchar(255),
sendValue float default 10,
paymentCash bool default false,
constraint fk_orders_client foreign key (idOrderClient) references clients(idClient)
	on update cascade
);

INSERT INTO orders (idOrderClient, orderStatus, orderDescription, sendValue, paymentCash)
VALUES
(1, 'Confirmado', 'Compra de Notebook', 20, false),
(2, 'Em Processamento', 'Compra de Camiseta e Boneca', 15, true),
(3, 'Cancelado', 'Compra de Sofá', 30, false),
(4, 'Confirmado', 'Compra de Chocolate', 10, true),
(5, 'Confirmado', 'Compra de Brinquedos variados', 25, false);

-- Criar tabela estoque 

create table productStorage(
idproductStorage int auto_increment primary key,
storageLocation varchar(255),
quantity int default 0
);

INSERT INTO productStorage (storageLocation, quantity)
VALUES
('Galpão SP', 100),
('Galpão RJ', 150),
('Galpão PR', 200),
('Galpão MG', 120),
('Galpão RS', 180);

-- Criar tabela fornecedor 

create table supplier(
idSupplier int auto_increment primary key,
socialName varchar(255) not null,
CNPJ char(15) not null, 
contact char(11) not null,
constraint unique_supplier unique (CNPJ)  
);

INSERT INTO supplier (socialName, CNPJ, contact)
VALUES
('TechMaster Ltda', '112223334444555', '11987654321'),
('Moda Brasil SA', '223334445556666', '11999887766'),
('Kids Toys ME', '334445556667777', '21988776655'),
('Delícias Alimentos', '445556667778888', '31977665544'),
('Conforto Móveis', '556667778889999', '41966554433');


-- Criar tabela vendedor 

create table seller(
idSeller int auto_increment primary key,
socialName varchar(255) not null,
abstName varchar(255),
CNPJ char(15) not null, 
CPF char(9),
location varchar(255),
contact char(11) not null,
constraint unique_cnpj_seller unique (CNPJ),
constraint unique_cpf_seller unique (CPF)    
);


INSERT INTO seller (socialName, abstName, CNPJ, CPF, location, contact)
VALUES
('Tech Vendas Ltda', 'TechVendas', '111222333444555', null, 'São Paulo', '11911112222'),
('Estilo Moda ME', 'EstiloModa', '222333444555666', null, 'Rio de Janeiro', '21922223333'),
('Brinquedos Alegria', 'BAlegria', '333444555666777', '123456789', 'Curitiba', '41933334444'),
('Doces&Cia', 'DocesCia', '444555666777888', null, 'Belo Horizonte', '31944445555'),
('Móveis Premium', 'MPremium', '555666777888999', '987654321', 'Porto Alegre', '51955556666');

create table productSeller(
    idPSeller int,
    idProduct int, 
	prodQuantity int default 1,
    primary key (idPSeller, idProduct),
    constraint fk_product_seller foreign key (idPSeller) references seller(idSeller),
	constraint fk_product_product foreign key (idProduct) references product(idProduct)
);

INSERT INTO productSeller (idPSeller, idProduct, prodQuantity)
VALUES
(1, 1, 10),
(2, 2, 30),
(3, 3, 25),
(4, 4, 50),
(5, 5, 15);


create table productOrder(
idPOproduct int, 
idPOorder int, 
poQuantity int default 1,
poStatus enum ('Disponível', 'Sem estoque') default 'Disponível',
primary key (idPOproduct, idPOorder),
constraint fk_productorder_seller foreign key (idPOproduct) references product(idProduct),
constraint fk_productorder_product foreign key (idPOorder) references orders(idOrder)
);

INSERT INTO productOrder (idPOproduct, idPOorder, poQuantity, poStatus)
VALUES
(1, 1, 1, 'Disponível'),
(2, 2, 2, 'Disponível'),
(3, 2, 1, 'Disponível'),
(5, 3, 1, 'Sem estoque'),
(4, 4, 3, 'Disponível');

create table storageLocation(
	
    idLproduct int,
    idLstorage int,
    location varchar(255) not null, 
    primary key (idLproduct, idLstorage),
    constraint fk_storage_location_product foreign key (idLproduct) references product(idProduct),
	constraint fk_storage_location_storage foreign key (idLstorage) references productStorage(idproductStorage)
);

INSERT INTO storageLocation (idLproduct, idLstorage, location)
VALUES
(1, 1, 'Setor A'),
(2, 2, 'Setor B'),
(3, 3, 'Setor C'),
(4, 4, 'Setor D'),
(5, 5, 'Setor E');

create table productSupplier(
	
    idPsSupplier int,
    idPsProduct int,
    quantity int not null,
    primary key (idPsSupplier, idPsProduct),
    constraint fk_product_supplier_supplier foreign key (idPsSupplier) references supplier(idSupplier),
	constraint fk_product_supplier_product foreign key (idPsProduct) references product(idProduct)
);

INSERT INTO productSupplier (idPsSupplier, idPsProduct, quantity)
VALUES
(1, 1, 50),
(2, 2, 100),
(3, 3, 70),
(4, 4, 200),
(5, 5, 40);

-- Entrega – Possui status e código de rastreio;

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


-- Queries --

select count(*) from clients;
select * from clients c, orders o 
	where c.idClient = idOrderClient;

select Fname, Lname, idOrder, orderStatus from clients c, orders o 
	where c.idClient = idOrderClient;

select concat(Fname,' ',Lname) as Cliente, idOrder as Pedido, orderStatus as Status from clients c, orders o 
	where c.idClient = idOrderClient;

select count(*) from clients c, orders o
		where c.idClient = idOrderClient
        group by idOrder;
        
        
select * from clients c 
	inner join orders o on c.idClient = o.idOrderClient
	inner join productOrder p on p.idPOorder = o.idOrder;
-- ----------------------------------------------------------------------------------
-- Queries para os desafios:
-- Recuperações simples com SELECT Statement
select * from product;
select Fname as Produto, category as Categoria from product;

-- Filtros com WHERE
select Fname, category, avaliação from product where category = 'Eletrônico';
select Fname, Lname, CPF from clients where CPF like '1%';

-- Expressões para gerar atributos derivados
-- Criando um campo com valor total do pedido (frete + R$ 20 como exemplo):
select 
    idOrder,
    orderDescription as Descrição,
    sendValue as Valor_Envio,
    sendValue + 20 AS Total
from orders;

-- Mostrando se o cliente paga com dinheiro (sim/não):
select 
    idOrder,
    orderDescription as Descrição_do_Produto,
    case 
        when paymentCash = true then 'Sim'
        else 'Não'
    end as Pagamento_em_dinheiro
from orders;

-- Ordenações com ORDER BY
-- Ordenando produtos da maior para a menor avaliação:
select Fname, avaliação
from product
order by avaliação desc;

-- Ordenando clientes pelo sobrenome:
select Fname, Lname
from clients
order by Lname asc;

-- Agrupamentos e filtros de grupo (GROUP BY + HAVING)
-- Contando quantos produtos há por categoria:
select category, COUNT(*) as TotalProdutos
from product
group by category;

-- Mostrando apenas as categorias com mais de 1 produto:
select category, COUNT(*) as TotalProdutos
from product
group by category
having COUNT(*) > 0;

-- Junções entre tabelas (INNER JOIN)
-- Mostrando os pedidos com o nome do cliente
select 
    o.idOrder,
    c.Fname as NomeCliente,
    o.orderDescription,
    o.orderStatus
from orders o
inner join clients c 
    on o.idOrderClient = c.idClient;

-- Mostrando os produtos e seus respectivos fornecedores
select 
    p.Fname as Produto,
    s.socialName as Fornecedor,
    ps.quantity as QuantidadeFornecida
from productSupplier ps
inner join product p on ps.idPsProduct = p.idProduct
inner join supplier s on ps.idPsSupplier = s.idSupplier;

-- RESPONDENDO PERGUNTAS DE NEGÓCIOS --
-- Quais são os nomes e CPFs de todos os clientes cadastrados?
select concat(Fname, ' ', Lname ) as Cliente, CPF from clients;

-- Quais produtos são da categoria "Brinquedos"?
select Fname, category from product
where category = 'Brinquedos';

-- Quais produtos têm avaliação maior que 4.5, em ordem decrescente?
select Fname, avaliação from product
where avaliação > 4.5
order by avaliação desc;

-- Quais clientes moram na “Rua das Flores”?
select Fname, Lname, Adress from clients
where Adress like '%Rua das Flores%';

-- Qual é a média de avaliação dos produtos por categoria?
select category, avg(avaliação) as media_avaliacao
from product
group by category;

-- Quantos produtos estão cadastrados em cada categoria?
select category, count(*) as total_produtos
from product
group by category;

-- Qual categoria tem mais produtos cadastrados (usando HAVING)?
select category, count(*) as total_produtos
from product
group by category
having total_produtos = (
    select max(contagem) 
    from (select count(*) as contagem from product group by category) as temp
);

-- Qual o valor total de frete (sendValue) de todos os pedidos confirmados?
select sum(sendValue) as total_frete
from orders
where orderStatus = 'Confirmado';

-- Quais clientes fizeram pedidos e quais produtos estavam nesses pedidos?
select c.Fname, c.Lname, p.Fname as Produto, o.orderStatus
from clients c
inner join orders o on c.idClient = o.idOrderClient
inner join productOrder po on o.idOrder = po.idPOorder
inner join product p on po.idPOproduct = p.idProduct;

-- Quais produtos estão sem estoque?
select p.Fname, po.poStatus
from product p
inner join productOrder po on p.idProduct = po.idPOproduct
where po.poStatus = 'Sem estoque';

-- Quais fornecedores fornecem cada produto e em que quantidade?
select s.socialName as Fornecedor, p.Fname as Produto, ps.quantity
from supplier s
inner join productSupplier ps on s.idSupplier = ps.idPsSupplier
inner join product p on ps.idPsProduct = p.idProduct;

-- Qual galpão armazena mais produtos (usando GROUP BY e ORDER BY)?
select ps.storageLocation, sum(ps.quantity) as total
from productStorage ps
group by ps.storageLocation
order by total desc;


