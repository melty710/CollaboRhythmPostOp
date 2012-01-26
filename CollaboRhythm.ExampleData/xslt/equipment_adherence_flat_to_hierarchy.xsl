<!--~
  ~ Copyright 2011 John Moore, Scott Gilroy
  ~
  ~ This file is part of CollaboRhythm.
  ~
  ~ CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
  ~ License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
  ~ version.
  ~
  ~ CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
  ~ warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  ~ details.
  ~
  ~ You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
  ~ <http://www.gnu.org/licenses/>.
  -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"

				xmlns:fn="http://www.w3.org/2005/xpath-functions"
				xmlns:d="http://indivo.org/vocab/xml/documents#">
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="/">
		<xsl:variable name="dateStartCustom" select="IndivoDocuments/BloodPressureAdherenceItem[1]/scheduleDateStart"/>
		<xsl:variable name="dateStart">
			<xsl:choose>
				<xsl:when test="$dateStartCustom">
					<xsl:value-of select="$dateStartCustom"/>
				</xsl:when>
				<xsl:otherwise>2011-07-15T13:00:00Z</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="dateEndCustom" select="IndivoDocuments/BloodPressureAdherenceItem[1]/scheduleDateEnd"/>
		<xsl:variable name="dateEnd">
			<xsl:choose>
				<xsl:when test="$dateEndCustom">
					<xsl:value-of select="$dateEndCustom"/>
				</xsl:when>
				<xsl:otherwise>2011-07-15T17:00:00Z</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="equipmentName" select="IndivoDocuments/BloodPressureAdherenceItem[1]/name"/>
		<xsl:variable name="equipmentType" select="IndivoDocuments/BloodPressureAdherenceItem[1]/equipmentType"/>
		<xsl:variable name="equipmentScheduleItemInstructions" select="IndivoDocuments/BloodPressureAdherenceItem[1]/instructions"/>
		<xsl:variable name="reportedBy" select="IndivoDocuments/BloodPressureAdherenceItem[1]/reportedBy"/>
		<xsl:variable name="recurrenceFrequency" select="IndivoDocuments/BloodPressureAdherenceItem[1]/recurrenceFrequency"/>
		<xsl:variable name="recurrenceInterval" select="IndivoDocuments/BloodPressureAdherenceItem[1]/recurrenceInterval"/>
		<xsl:variable name="recurrenceCount" select="IndivoDocuments/BloodPressureAdherenceItem[1]/recurrenceCount"/>
		<IndivoDocuments>
			<LoadableIndivoDocument>
				<document>
					<Equipment xmlns="http://indivo.org/vocab/xml/documents#">
						<dateStarted>2009-12-15</dateStarted>
						<type>
							<xsl:choose>
								<xsl:when test="$equipmentType != ''">
									<xsl:value-of select="$equipmentType"/>
								</xsl:when>
								<xsl:otherwise>blood pressure monitor</xsl:otherwise>
							</xsl:choose>
						</type>
						<xsl:copy-of select="$equipmentName"/>
					</Equipment>
				</document>
				<relatesTo>
					<relation type="scheduleItem">
						<!-- child elements can be either (1) IndivoDocumentWithRelationships or (2) IndivoDocument document type -->
						<LoadableIndivoDocument>
							<document>
								<EquipmentScheduleItem xmlns="http://indivo.org/vocab/xml/documents#">
									<xsl:copy-of select="$equipmentName"/>
									<scheduledBy>jking@records.media.mit.edu</scheduledBy>
									<dateScheduled>2011-07-14T19:13:11Z</dateScheduled>
									<dateStart>
										<xsl:value-of select="$dateStart"/>
									</dateStart>
									<dateEnd>
										<xsl:value-of select="$dateEnd"/>
									</dateEnd>
									<recurrenceRule>
										<xsl:choose>
											<xsl:when test="$recurrenceFrequency != ''">
												<frequency><xsl:value-of select="$recurrenceFrequency"/></frequency>
											</xsl:when>
											<xsl:otherwise>
												<frequency>DAILY</frequency>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:if test="$recurrenceInterval != ''">
											<interval><xsl:value-of select="$recurrenceInterval"/></interval>
										</xsl:if>
										<xsl:choose>
											<xsl:when test="$recurrenceCount != ''">
												<count><xsl:value-of select="$recurrenceCount"/></count>
											</xsl:when>
											<xsl:otherwise>
												<count>90</count>
											</xsl:otherwise>
										</xsl:choose>
									</recurrenceRule>
									<xsl:copy-of select="$equipmentScheduleItemInstructions"/>
								</EquipmentScheduleItem>
							</document>
							<relatesTo>
								<relation type="adherenceItem">
									<xsl:for-each select="IndivoDocuments/BloodPressureAdherenceItem">
										<xsl:variable name="adherenceCount" select="position() - 1"/>
										<LoadableIndivoDocument>
											<document>
												<AdherenceItem xmlns="http://indivo.org/vocab/xml/documents#">
													<xsl:copy-of select="$equipmentName"/>
													<xsl:copy-of select="$reportedBy"/>
													<dateReported>
														<xsl:value-of select="dateReported"/>
													</dateReported>
													<recurrenceIndex>
														<xsl:choose>
															<xsl:when test="recurrenceIndex">
																<xsl:value-of select="recurrenceIndex"/>
															</xsl:when>
															<xsl:otherwise>
																<xsl:value-of
																		select="fn:days-from-duration(xs:dateTime(dateReported) - xs:dateTime($dateStart))"/>
															</xsl:otherwise>
														</xsl:choose>
													</recurrenceIndex>
													<adherence>
														<xsl:value-of select="adherence"/>
													</adherence>
												</AdherenceItem>
											</document>
											<xsl:if test="adherence='true'">
												<relatesTo>
													<relation type="adherenceResult">
														<!-- TODO: test if contains for each of the vitals; add bloodGlucose-->
														<xsl:if test="systolic">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name type="http://codes.indivo.org/vitalsigns/" value="123" abbrev="BPsys">Blood Pressure Systolic</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="systolic"/></value>
																			<unit type="http://codes.indivo.org/units/" value="31" abbrev="mmHg">millimeters of mercury</unit>
																		</result>
																		<site>left arm</site>
																		<position>sitting</position>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="diastolic">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name type="http://codes.indivo.org/vitalsigns/" value="124" abbrev="BPdia">Blood Pressure Diastolic</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="diastolic"/></value>
																			<unit type="http://codes.indivo.org/units/" value="31" abbrev="mmHg">millimeters of mercury</unit>
																		</result>
																		<site>left arm</site>
																		<position>sitting</position>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="heartRate">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name type="http://codes.indivo.org/vitalsigns/" value="125" abbrev="HR">Heart Rate</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="heartRate"/></value>
																			<unit type="http://codes.indivo.org/units/" value="30" abbrev="bpm">beats per minute</unit>
																		</result>
																		<site>left arm</site>
																		<position>sitting</position>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="bloodGlucose">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name>Blood Glucose</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="bloodGlucose"/></value>
																			<unit abbrev="mg/dL">milligrams per deciliter</unit>
																		</result>
																		<site>abdomen</site>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="peakFlow">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name>Peak Expiratory Flow Rate</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="peakFlow"/></value>
																			<unit abbrev="L/min">litres/minute</unit>
																		</result>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="durationOfExercise">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name>Duration of Exercise</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="durationOfExercise"/></value>
																			<unit abbrev="sec">seconds</unit>
																		</result>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="metabolicEquivalent">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name>Metabolic Equivalent Task</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="metabolicEquivalent"/></value>
																			<unit abbrev="met">met</unit>
																		</result>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="oxygenSaturation">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name>Oxygen Saturation</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="oxygenSaturation"/></value>
																			<unit abbrev="%">percent</unit>
																		</result>
																		<site>abdomen</site>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="fluid">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name>Fluid Intake</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="fluid"/></value>
																			<unit abbrev="cups">cups</unit>
																		</result>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="food">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name>Food Level</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value>
																				<xsl:choose>
																					<xsl:when test="food = 'more'">1</xsl:when>
																					<xsl:when test="food = 'less'">-1</xsl:when>
																					<xsl:when test="food = 'same'">0</xsl:when>
																					<xsl:otherwise>0</xsl:otherwise>
																				</xsl:choose>
																			</value>
																			<textValue><xsl:value-of select="food"/></textValue>
																			<unit>Delta from Average</unit>
																		</result>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="urineoutone">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name>Food Level</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="urineoutone"/></value>
																			<unit abbrev="mL">millileters</unit>
																		</result>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
														<xsl:if test="urineouttwo">
															<LoadableIndivoDocument>
																<document>
																	<VitalSign
																			xmlns="http://indivo.org/vocab/xml/documents#">
																		<name>Food Level</name>
																		<measuredBy><xsl:value-of select="$reportedBy"/></measuredBy>
																		<dateMeasuredStart>
																			<xsl:value-of select="dateReported"/>
																		</dateMeasuredStart>
																		<result>
																			<value><xsl:value-of select="urineouttwo"/></value>
																			<unit abbrev="mL">millileters</unit>
																		</result>
																	</VitalSign>
																</document>
															</LoadableIndivoDocument>
														</xsl:if>
													</relation>
												</relatesTo>
											</xsl:if>
										</LoadableIndivoDocument>
									</xsl:for-each>
								</relation>
							</relatesTo>
						</LoadableIndivoDocument>
<!--
						<LoadableIndivoDocument>
							<document>
								<EquipmentScheduleItem xmlns="http://indivo.org/vocab/xml/documents#">
									<xsl:copy-of select="$equipmentName"/>
									<scheduledBy>jking@records.media.mit.edu</scheduledBy>
									<dateScheduled>2011-07-28T19:13:11Z</dateScheduled>
									<dateStart>2011-07-29T13:00:00Z</dateStart>
									<dateEnd>2011-07-29T17:00:00Z</dateEnd>
									<recurrenceRule>
										<frequency>DAILY</frequency>
										<count>90</count>
									</recurrenceRule>
									<instructions>press the power button and wait several seconds to take reading
									</instructions>
								</EquipmentScheduleItem>
							</document>
						</LoadableIndivoDocument>
-->
					</relation>
				</relatesTo>
			</LoadableIndivoDocument>
		</IndivoDocuments>
	</xsl:template>

</xsl:stylesheet>