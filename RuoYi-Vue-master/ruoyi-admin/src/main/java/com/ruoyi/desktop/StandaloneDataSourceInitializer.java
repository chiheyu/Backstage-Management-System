package com.ruoyi.desktop;

import javax.sql.DataSource;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Profile;
import org.springframework.core.PriorityOrdered;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.stereotype.Component;

@Component
@Profile("standalone")
public class StandaloneDataSourceInitializer implements BeanPostProcessor, PriorityOrdered
{
    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException
    {
        if (!"masterDataSource".equals(beanName) || !(bean instanceof DataSource))
        {
            return bean;
        }

        DataSource dataSource = (DataSource) bean;
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        Integer count = jdbcTemplate.queryForObject(
                "select count(*) from information_schema.tables where lower(table_name) = 'sys_config'",
                Integer.class);
        if (count != null && count > 0)
        {
            return bean;
        }

        ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
        populator.addScript(new ClassPathResource("db/h2/schema.sql"));
        populator.addScript(new ClassPathResource("db/h2/data.sql"));
        populator.execute(dataSource);
        return bean;
    }

    @Override
    public int getOrder()
    {
        return PriorityOrdered.HIGHEST_PRECEDENCE;
    }
}
