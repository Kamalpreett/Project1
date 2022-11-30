SELECT *
FROM [Portfolio Project]..CovidDeaths
ORDER BY 3,4


SELECT *
FROM [Portfolio Project]..CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2

---Looking at Total Cases vs Total Deaths
---Shows likelihood of dying if you contracts Covid in your country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS INT)/CAST(total_cases AS INT))*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
where location like '%Emirates%'

---Looking at Total Cases vs Population
---Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (CAST(total_cases AS INT)/CAST(population AS INT))*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
where location like '%Emirates%'

---Looking at Countries highest infection rate compared to population
---Shows what percentage of population got covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
WHERE population IS NOT NULL AND population <>0
order by 1,2

ALTER TABLE dbo.covidDeaths
ALTER COLUMN total_cases int

ALTER TABLE dbo.covidDeaths
ALTER COLUMN population bigint

ALTER TABLE dbo.covidDeaths
ALTER COLUMN new_cases int

---Showing Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS  NOT NULL
GROUP BY location
order by TotalDeathCount

---Let's break things down by Continent
---Showing the continents with highest death count
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS  NOT NULL
GROUP BY continent
order by TotalDeathCount

---Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

---Looking at Total Population vs Vaccinations
---Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

---Using CTE to perform Calculation on Partition by in previous Query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 