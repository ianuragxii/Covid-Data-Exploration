
select *
From PortfolioProject..CovidDeath
where continent is not null
order by 3,4

--select *
--From PortfolioProject..CovidVaccination
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
where continent is not null
order by 1,2


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
where location like '%states%'
and continent is not null
order by 1,2 

Select Location, date,population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeath
--where location like '%states%'
order by 1,2 



Select Location, population, MAX(total_cases) as HighestInfectedCount, MAX(total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeath
--where location like '%states%' 
Group by Location, population
order by InfectedPopulationPercentage desc



Select Location, Population,date, MAX(total_cases) as HighestInfectedCount,  Max((total_cases/population))*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
Group by Location, Population, date
order by InfectedPopulationPercentage desc



Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
where location like '%states%'
and continent is not null
order by 1,2 


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.Location)
FROM PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3



with PopvsVac (Continent,Location,Date,Population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *
From PopvsVac



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
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




Create View PercentPopulationVaccinated 

as Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
