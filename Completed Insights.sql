SELECT *
FROM PortFolioProject..CovidDeaths
ORDER BY 3, 4 ;

--SELECT *
--FROM PortFolioProject..CovidVaccinations
--ORDER BY 3, 4 ;  

--Data we are going to use !

Select location, date, total_cases, new_cases, total_deaths, population
from PortFolioProject..CovidDeaths
order by 1, 2;

-- Total Cases VS Total Deaths
-- Death will more Likely be less percentage

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortFolioProject..CovidDeaths
where location = 'india'
order by 1, 2;

-- Total cases VS Population
--Total number of People who are not Effected

Select location, date, total_cases, population, (total_cases/population)*100 as Effected_percentage
from PortFolioProject..CovidDeaths
--where location = 'india'
order by 1, 2;

-- Countries with Highest Infection Rate

Select location, MAX(total_cases) as HighestEffectedRate, population, MAX((total_cases/population))*100 as Effected_percentage
from PortFolioProject..CovidDeaths
--where location = 'india'
group by location, population
order by Effected_percentage desc;


-- Countries with Highest Deaths Over Population

Select location, MAX(cast(total_deaths as int)) as HighestDeathRate
from PortFolioProject..CovidDeaths
--where date like  '%2021%'
where continent is not null
group by location
order by HighestDeathRate desc; 

-- Continent Wise Analysis

--The Highest Death count in Continents

Select continent, MAX(cast(total_deaths as int)) as HighestDeathRate
from PortFolioProject..CovidDeaths
where date like  '%2021%'
and continent is not null
group by continent
order by HighestDeathRate desc;  

-- Global Numbers

Select  sum(new_cases) as TotalCasesGlobally, SUM(cast(new_deaths as int)) as TotalDeathsGlobally, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortFolioProject..CovidDeaths
-- where location = 'india'
where continent is not null
--group by date
order by 1, 2;



-- Total Population VS Total Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by  2, 3 


----------- Using CTE ----------

with PopvsVac (Continent, location, date, population, new_vaccination, RollingPeopleVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by  2, 3 
)
select *, (RollingPeopleVaccination/population)*100
from PopvsVac
 

 -- Temp Table


 Drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccination numeric
 )

 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by  2, 3

select *, (RollingPeopleVaccination/population)*100
from #PercentPopulationVaccinated
 


 -- Creating Views to Store Data for Later Visualization 

 create view [PercentPopulationVaccinated] as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by  2, 3


select * from PercentPopulationVaccinated; 



