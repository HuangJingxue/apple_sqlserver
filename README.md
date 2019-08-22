```text
官方SQLServer学习：https://docs.microsoft.com/zh-cn/sql/sql-server/tutorials-for-sql-server-2016?view=sql-server-2017
官方Microsoft sqlserver 免费版下载地址：https://www.microsoft.com/zh-cn/sql-server/sql-server-downloads
SQLServer版本下载：https://msdn.itellyou.cn/
官方Microsoft SQL文档链接：https://docs.microsoft.com/zh-cn/sql/?view=sql-server-2017#pivot=sqlserver&panel=sqlserver
官方DBCC文档链接：https://docs.microsoft.com/zh-cn/sql/t-sql/database-console-commands/dbcc-transact-sql?view=sql-server-2017
用于 SQL Server mssql cli 命令行查询工具：https://docs.microsoft.com/zh-cn/sql/tools/mssql-cli?view=sql-server-2017
SQLServer指南：https://docs.microsoft.com/zh-cn/sql/relational-databases/sql-server-guides?view=sql-server-2017
sql-server-samples：https://github.com/Microsoft/sql-server-samples/tree/master/samples
SQLServer常见备份：http://mysql.taobao.org/monthly/2017/11/03/
SQLServer按时间点备份还原：https://docs.microsoft.com/zh-cn/sql/t-sql/statements/restore-statements-transact-sql?view=sql-server-2017#restoring_to_pit_using_STOPAT
SQLServer维护计划向导：https://docs.microsoft.com/zh-cn/sql/relational-databases/maintenance-plans/use-the-maintenance-plan-wizard?view=sql-server-2017&viewFallbackFrom=sql-server-previousversions
SQLServer性能查看：
1、https://docs.microsoft.com/zh-cn/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store?view=sql-server-2017
2、https://docs.microsoft.com/zh-cn/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-query-stats-transact-sql?view=sql-server-2017

MSSQL错误：https://docs.microsoft.com/zh-cn/sql/relational-databases/errors-events/database-engine-events-and-errors?view=sql-server-2017#errors-16000-to-17999

基础版与高可用版本区别
参考：https://help.aliyun.com/document_detail/48980.html?spm=5176.11065259.1996646101.searchclickresult.1c6329b7pcYogT

使用限制
参考：https://help.aliyun.com/document_detail/26141.html?spm=5176.product26090.6.594.xny8sX

SQLServer2012降级到SQLServer2008
参考：https://yq.aliyun.com/articles/59964

RDS SQL Server各版本实例的功能差异
参考：https://help.aliyun.com/document_detail/44534.html?spm=5176.doc53729.2.9.DxchZR

独享型
参考：https://help.aliyun.com/document_detail/49875.html?spm=5176.11065259.1996646101.searchclickresult.26738137kIfIgI

SQLServer WEB 和SQLServer EE的区别
参考：https://technet.microsoft.com/zh-cn/library/cc645993(v=sql.110).aspx
```
常见报错：
17300  SQL Server 无法运行新的系统任务，原因是内存不足或配置的会话数超过了服务器允许的最大数。 请查看服务器是否有足够的内存。 请使用 sp_configure 以及选项 '用户连接' 查看允许的最大用户连接数。 请使用 sys.dm_exec_sessions 检查当前会话数，包括用户进程。

查看当前服务器名
```sql
select @@Servername
```


--查看库中表信息
```sql
SELECT * FROM sys.tables
where object_id =  245575913
```

--查看表结构
```sql
USE hjx;  
GO  
EXEC sp_help t2;  
GO
```
--查看表中列信息
```sql
sp_columns t2
```
--快速查看表结构（比较全面的）
```sql
SELECT  CASE WHEN col.colorder = 1 THEN obj.name
                  ELSE ''
             END AS 表名,
        col.colorder AS 序号 ,
        col.name AS 列名 ,
        ISNULL(ep.[value], '') AS 列说明 ,
        t.name AS 数据类型 ,
        col.length AS 长度 ,
        ISNULL(COLUMNPROPERTY(col.id, col.name, 'Scale'), 0) AS 小数位数 ,
        CASE WHEN COLUMNPROPERTY(col.id, col.name, 'IsIdentity') = 1 THEN '√'
             ELSE ''
        END AS 标识 ,
        CASE WHEN EXISTS ( SELECT   1
                           FROM     dbo.sysindexes si
                                    INNER JOIN dbo.sysindexkeys sik ON si.id = sik.id
                                                              AND si.indid = sik.indid
                                    INNER JOIN dbo.syscolumns sc ON sc.id = sik.id
                                                              AND sc.colid = sik.colid
                                    INNER JOIN dbo.sysobjects so ON so.name = si.name
                                                              AND so.xtype = 'PK'
                           WHERE    sc.id = col.id
                                    AND sc.colid = col.colid ) THEN '√'
             ELSE ''
        END AS 主键 ,
        CASE WHEN col.isnullable = 1 THEN '√'
             ELSE ''
        END AS 允许空 ,
        ISNULL(comm.text, '') AS 默认值
FROM    dbo.syscolumns col
        LEFT  JOIN dbo.systypes t ON col.xtype = t.xusertype
        inner JOIN dbo.sysobjects obj ON col.id = obj.id
                                         AND obj.xtype = 'U'
                                         AND obj.status >= 0
        LEFT  JOIN dbo.syscomments comm ON col.cdefault = comm.id
        LEFT  JOIN sys.extended_properties ep ON col.id = ep.major_id
                                                      AND col.colid = ep.minor_id
                                                      AND ep.name = 'MS_Description'
        LEFT  JOIN sys.extended_properties epTwo ON obj.id = epTwo.major_id
                                                         AND epTwo.minor_id = 0
                                                         AND epTwo.name = 'MS_Description'
WHERE   obj.name = 't2'--表名
ORDER BY col.colorder ;
```  
-- 查看索引
```sql
USE hjx;  
GO  
EXEC sp_helpindex N't1';  
GO
```
-- 获取没有主键的所有用户表
```sql
SELECT SCHEMA_NAME(schema_id) AS schema_name  
    ,name AS table_name   
FROM sys.tables   
WHERE OBJECTPROPERTY(object_id,'TableHasPrimaryKey') = 0  
ORDER BY schema_name, table_name;  
GO

适用范围：SQL Server 2016 (13.x) 到 SQL Server 2017 和 Azure SQL Database。

SELECT T1.object_id, T1.name as TemporalTableName, SCHEMA_NAME(T1.schema_id) AS TemporalTableSchema,  
T2.name as HistoryTableName, SCHEMA_NAME(T2.schema_id) AS HistoryTableSchema,  
T1.temporal_type_desc  
FROM sys.tables T1  
LEFT JOIN sys.tables T2   
ON T1.history_table_id = T2.object_id  
ORDER BY T1.temporal_type desc  
```
-- 查看空间信息
-- 查看所有数据库的日志空间信息
```sql
DBCC SQLPERF(LOGSPACE);  
GO
```

-- 收缩文件 日志文件
```sql
USE [hjx]
GO
DBCC SHRINKFILE (N'hjx_log' , 0, TRUNCATEONLY)
GO
```
-- 收缩文件 数据文件
```sql
USE [hjx]
GO
DBCC SHRINKFILE (N'hjx' , 0, TRUNCATEONLY)
GO
```
