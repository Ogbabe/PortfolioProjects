--SELECT *
--FROM PortfolioProject..CovidDeaths

--SELECT *
--FROM PortfolioProject..CovidVaccinations

--Analyzing CovidDeaths by location--
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

---calculating total_cases versus total_deaths--
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM Portfolioproject..CovidDeaths
WHERE location LIKE '%States%'
ORDER BY 1,2

---% of population that contracted Covid--
SELECT location,date,total_cases,new_cases,total_deaths,population,(total_cases/population)*100 AS Percentageinfected
FROM PortfolioProject..CovidDeaths
ORDER BY Percentageinfected desc

--countries with the higest infection rate compared to population--
SELECT location,MAX(total_cases) AS Highestinfectioncount, MAX(total_cases/population)*100 AS Percentagepopulationinfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%States%'
GROUP BY location,population
ORDER BY Percentagepopulationinfected desc

---countries with the highest death count per population
SELECT location, MAX(total_deaths) AS total_deathcount
FROM Portfolioproject..CovidDeaths
---WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deathcount desc

---Analysing Coviddeaths by Continent---
---continents with the highest deathcount per population---
SELECT continent, MAX(Cast(total_deaths AS int)) AS total_deathcount
FROM Portfolioproject..CovidDeaths
---WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deathcount desc

---date with the highest deathcount ---
SELECT date, SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths
FROM Portfolioproject..CovidDeaths
---WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

---%tage values of covidDeaths---
SELECT date,SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths,SUM(CAST(new_deaths AS int))/SUM(new_cases) *100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
---WHERE location is '%States%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

---Analyzing Covidvaccinations----
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2

---total Populations Vs Vaccinations----
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date,dea.location) as total_vaccinations
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location 
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 2,3

 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.location) AS RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/Population)* 100
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location 
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 2,3


 ---USING CTE to find Population versus vaccinations---
 WITH PopVsVac(continent,location,date,Population,new_vaccinations,RollingPeoplevaccinated) 
 AS
 (
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/Population)* 100
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location 
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 ---ORDER BY 2,3
 )
 SELECT * 
 FROM PopVsvac

 --creating temporary tables---
 DROP table if exists #PercentpopulationVaccinated
 CREATE table #Percentagepopulationvaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date Datetime,
 Population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 insert into #Percentpopulationvaccinated
  SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/Population)* 100
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location 
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 ---ORDER BY 2,3
 SELECT *,(RollingPeoplevaccinated/population) * 100
 FROM #Percentpopulationvaccinated

 --- Creating views to store data for visualization---
 CREATE View PercentPopulationVaccination AS
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/Population)* 100
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location 
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 ---ORDER BY 2,3
 
 ---determining the top 1000 data input in all columns----
 SELECT Top (1000) [continent]
				  ,[date]
				  ,[population]
				  ,[new_vaccinations]
				  ,[RollingPeoplevaccinated]
			 FROM [PortfolioProject].[dbo].[PercentPopulationVaccination]
WHERE continent IS NOT NULL
ORDER BY 2,3
