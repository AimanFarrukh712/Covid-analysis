Select *
From PortfolioProject..CovidDeath order by 3,4 

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeath
where continent is not null 
order by 1,2

--total cases vs total deaths
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
where location like '%states%'
and continent is not null
order by 1,2

--total cases vs total population 
Select Location, date, Population, total_cases, (total_Cases/population)*100 as PercentPeopleInfected
FROM PortfolioProject..CovidDeath
where location like '%states'
order by 1,2 

--countries with highest infected rates comapared to population 
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeath
Group by location, population
order by PercentPopulationInfected desc

--countries with highest death count per population 
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
WHERE continent is not null 
Group BY location
order by TotalDeathCount desc

--showing continents with the highest death count per popultion 
select continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers 
select location, SUM(new_cases) as total_Cases, SUM(cast(new_Deaths as int)) as total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DaethPercentage
from PortfolioProject..CovidDeath
where continent is not null
Group by location 
order by 1,2

select * from PortfolioProject..CovidVaccinations





--total populations vs Vaccinations 
--shows percentaage of population that has received at least one covid vaccine 
Select dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated, SUM(convert(bigint, vac.people_vaccinated)) OVER (Partition by dea.location order by dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
             on dea.location = vac.location
			 and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- Using CTE to perform Calculation on Partition By in previous query 

With PopvsVac(Continent, Location, Date, population, people_vaccinated, RollingPeopoleVaccinated) 
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated, SUM(convert(bigint, vac.people_vaccinated)) OVER (Partition by dea.location order by dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
             on dea.location = vac.location
			 and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopoleVaccinated/population)*100 as percentagePeopleVaccinated from PopvsVac

--temp table
DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
people_vaccinated numeric, 
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated, SUM(convert(bigint, vac.people_vaccinated)) OVER (Partition by dea.location order by dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
             on dea.location = vac.location
			 and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
Select *, (RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated

--Creating View to store data for later visualiations 

create view PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated, SUM(convert(bigint, vac.people_vaccinated)) OVER (Partition by dea.location order by dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
             on dea.location = vac.location
			 and dea.date = vac.date
where dea.continent is not null
 
