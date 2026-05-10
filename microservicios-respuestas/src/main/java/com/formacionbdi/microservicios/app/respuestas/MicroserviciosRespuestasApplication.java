package com.formacionbdi.microservicios.app.respuestas;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@EnableDiscoveryClient
@SpringBootApplication
@EntityScan({"com.formacionbdi.microservicios.app.respuestas.models.entity",
	"com.formacionbdi.microservicios.commons.alumnos.models.entity",
	"com.formacionbdi.microservicios.commons.examenes.models.entity"})
public class MicroserviciosRespuestasApplication {

	public static void main(String[] args) {
		SpringApplication.run(MicroserviciosRespuestasApplication.class, args);
	}

}
