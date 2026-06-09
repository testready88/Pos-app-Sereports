//package com.ms.semicolans.sereportapi.sereportapi.config;
//
//
//import jakarta.persistence.EntityManagerFactory;
//import org.springframework.beans.factory.annotation.Qualifier;
//import org.springframework.boot.context.properties.ConfigurationProperties;
//import org.springframework.boot.jdbc.DataSourceBuilder;
//import org.springframework.boot.orm.jpa.EntityManagerFactoryBuilder;
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.context.annotation.Primary;
//import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
//import org.springframework.jdbc.core.JdbcTemplate;
//import org.springframework.orm.jpa.JpaTransactionManager;
//import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
//import org.springframework.transaction.PlatformTransactionManager;
//import org.springframework.transaction.annotation.EnableTransactionManagement;
//
//import javax.sql.DataSource;
//
//@Configuration
//@EnableTransactionManagement
//@EnableJpaRepositories(
//        basePackages = "com.ms.semicolans.sereportapi.sereportapi.repo.companydb",
//        entityManagerFactoryRef = "companyEntityManagerFactory",
//        transactionManagerRef = "companyTransactionManager"
//)
//public class CompanyDBConfig {
//    @Primary
//    @Bean(name = "companyDataSource")
//    @ConfigurationProperties(prefix = "spring.datasource.companydb")
//    public DataSource dataSource() {
//        return DataSourceBuilder.create().build();
//    }
//
//    @Primary
//    @Bean(name = "companyEntityManagerFactory")
//    public LocalContainerEntityManagerFactoryBean entityManagerFactory(
//            EntityManagerFactoryBuilder builder,
//            @Qualifier("companyDataSource") DataSource dataSource) {
//        return builder
//                .dataSource(dataSource)
//                .packages("com.ms.semicolans.sereportapi.sereportapi.entity.company") // Define user entity package
//                .persistenceUnit("companydb")
//                .build();
//    }
//
//
//    @Bean(name = "companyTransactionManager")
//    public PlatformTransactionManager transactionManager(
//            @Qualifier("companyEntityManagerFactory") EntityManagerFactory entityManagerFactory) {
//        return new JpaTransactionManager(entityManagerFactory);
//    }
//
//
//    @Bean(name = "companyJdbcTemplate")
//    public JdbcTemplate companyJdbcTemplate(@Qualifier("companyDataSource") DataSource dataSource) {
//        return new JdbcTemplate(dataSource);
//    }
//}
