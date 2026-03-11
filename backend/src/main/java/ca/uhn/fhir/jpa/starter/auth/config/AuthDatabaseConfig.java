package ca.uhn.fhir.jpa.starter.auth.config;

import ca.uhn.fhir.jpa.starter.auth.model.User;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;

@Configuration
@EnableJpaRepositories(basePackages = "ca.uhn.fhir.jpa.starter.auth.repository")
public class AuthDatabaseConfig {
	
	@Bean
	public BeanPostProcessor entityManagerPostProcessor() {
		return new BeanPostProcessor() {
			@Override
			public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
				if (bean instanceof LocalContainerEntityManagerFactoryBean) {
					LocalContainerEntityManagerFactoryBean emfb = (LocalContainerEntityManagerFactoryBean) bean;
					emfb.setPackagesToScan(
							"ca.uhn.fhir.jpa.model.entity",
							"ca.uhn.fhir.jpa.entity",
							"ca.uhn.fhir.jpa.starter.auth.model"
					);
				}
				return bean;
			}
		};
	}
}
